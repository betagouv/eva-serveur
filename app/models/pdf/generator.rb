module Pdf
  class Generator
    # Le job tourne sur un worker dédié, isolé du trafic web : on peut se
    # permettre d'attendre le chargement de la page plus longtemps que le
    # défaut Puppeteer (30s)
    TIMEOUT_CHARGEMENT = 60_000

    def generate(html_content, filename: "document-#{SecureRandom.uuid}")
      page = nil
      browser_ref = Pdf::Browser.instance
      page = prepare_page(browser_ref, html_content)

      page.pdf(**pdf_options(filename: filename))
      page.close
      file_path(filename)
    rescue => e
      Rails.logger.error("Chromium crash: #{e.message}")
      Rollbar.error(e)
      retablissement_apres_crash(browser_ref, page)
      false
    end

    def self.generate(html_content)
      new.generate(html_content)
    end

    def retablissement_apres_crash(browser, page)
      if browser&.connected?
        action = "fermeture page"
        page&.close
      else
        action = "reset navigateur"
        Pdf::Browser.reset!
      end
    rescue => e
      Rails.logger.debug("Échec #{action} après erreur: #{e.message}")
    end

    def prepare_page(browser, html_content)
      page = browser.new_page
      page.viewport = Pdf::Browser::A4_VIEWPORT
      compteur = surveille_requetes(page)

      page.set_content(html_content, wait_until: "load", timeout: TIMEOUT_CHARGEMENT)
      attend_reseau_stabilise(page)
      pause_pdf if Pdf::Browser.debug_mode?
      page
    ensure
      journalise_requetes(compteur)
    end

    # wait_for_network_idle (fourni par puppeteer-ruby) peut ne jamais se
    # résoudre : quand deux requêtes identiques quasi simultanées (ex. la
    # même icône SVG DSFR utilisée plusieurs fois sur la page) sont
    # coalescées par Chromium en une seule requête réseau réelle, deux
    # requestId CDP distincts sont tout de même créés côté navigateur, et
    # l'un d'eux ne reçoit jamais d'événement terminal
    # (Network.loadingFinished/loadingFailed, traduit par Puppeteer en
    # requestfinished/requestfailed). Bug connu et non résolu de Puppeteer
    # (cf. puppeteer/puppeteer#11641). En revanche Network.responseReceived
    # (l'événement "response") se déclenche bien pour la requête fantôme :
    # on reproduit donc ici la logique de wait_for_network_idle en suivant
    # les requêtes en cours via "response"/"requestfailed" plutôt que via
    # "requestfinished" seul.
    def attend_reseau_stabilise(page, idle_time: 500, timeout: TIMEOUT_CHARGEMENT, concurrency: 2)
      en_attente = {}
      promise = Async::Promise.new
      programme_idle, interrompt_idle = gestion_idle(en_attente, promise, idle_time, concurrency)

      ecouteurs = ecoute_stabilite_reseau(page, en_attente, programme_idle, interrompt_idle)
      programme_idle.call

      attend_promesse(promise, timeout)
    ensure
      page.remove_event_listener(*ecouteurs) if ecouteurs
      interrompt_idle&.call
    end

    def gestion_idle(en_attente, promise, idle_time, concurrency)
      idle_timer = nil
      programme_idle = lambda do
        next if en_attente.size > concurrency

        idle_timer&.stop
        idle_timer = Async do
          Puppeteer::AsyncUtils.sleep_seconds(idle_time / 1000.0)
          promise.resolve(nil) unless promise.resolved? || en_attente.size > concurrency
        end
      end
      interrompt_idle = lambda do
        idle_timer&.stop
        idle_timer = nil
      end
      [ programme_idle, interrompt_idle ]
    end

    def ecoute_stabilite_reseau(page, en_attente, programme_idle, interrompt_idle)
      ecouteur_requete = page.add_event_listener("request") do |requete|
        en_attente[requete] = true
        interrompt_idle.call
      end
      ecouteur_reponse = page.add_event_listener("response") do |reponse|
        en_attente.delete(reponse.request)
        programme_idle.call
      end
      ecouteur_echec = page.add_event_listener("requestfailed") do |requete|
        en_attente.delete(requete)
        programme_idle.call
      end
      [ ecouteur_requete, ecouteur_reponse, ecouteur_echec ]
    end

    def attend_promesse(promise, timeout)
      Puppeteer::AsyncUtils.async_timeout(timeout, -> { promise.wait }).wait
    rescue Async::TimeoutError
      Rails.logger.warn("PDF: attente reseau stabilise interrompue apres #{timeout}ms")
    end

    def surveille_requetes(page)
      compteur = { total: 0, en_cours: {} }
      page.on("request") do |requete|
        compteur[:total] += 1
        compteur[:en_cours][requete.url] = true
      end
      page.on("requestfinished") { |requete| compteur[:en_cours].delete(requete.url) }
      page.on("requestfailed") { |requete| compteur[:en_cours].delete(requete.url) }
      compteur
    end

    def journalise_requetes(compteur)
      return unless compteur

      Rails.logger.info("PDF: #{compteur[:total]} requetes reseau chargees")
      return if compteur[:en_cours].empty?

      urls = compteur[:en_cours].keys.join(", ")
      Rails.logger.warn("PDF: #{compteur[:en_cours].size} requete(s) jamais terminee(s) : #{urls}")
    end

    # Le mode debug permet d'ouvrir une page chrome pour visualiser le rendu
    # et inspecter l'html avant la transformation en PDF
    def pause_pdf
      Rails.logger.debug 'Appuyer sur la touche "Entrer" pour continuer le processus'
      gets # Attend que l'utilisateur appuie sur "Enter" (dans le terminal du serveur)
    end

    def pdf_options(filename:, format: "A4", landscape: false)
      {
        path: file_path(filename),
        print_background: true,
        format: format,
        landscape: landscape,
        margin: { top: "0px", right: "0px", bottom: "0px", left: "0px" }
      }
    end

    def file_path(filename)
      dir_path = Rails.root.join("tmp/pdf")
      FileUtils.mkdir_p(dir_path)
      dir_path.join("#{filename}.pdf")
    end
  end
end
