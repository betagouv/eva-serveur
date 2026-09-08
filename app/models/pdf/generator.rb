module Pdf
  class Generator
    # Le job tourne sur un worker dédié, isolé du trafic web : on peut se
    # permettre d'attendre plus longtemps que le défaut Puppeteer (30s),
    # qui peut être dépassé par de grosses évaluations (beaucoup de
    # requêtes HTTP réelles vers l'app elle-même pour charger CSS/JS/SVG).
    TIMEOUT_CHARGEMENT = 120_000

    def generate(html_content, filename: "document-#{SecureRandom.uuid}")
      page = nil
      browser_ref = nil
      Pdf::Browser.instance do |browser|
        browser_ref = browser
        page = prepare_page(browser, html_content)

        page.pdf(**pdf_options(filename: filename))
        page.close
        file_path(filename)
      end
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

      if Rails.env.development?
        page.set_content(
          html_content,
          wait_until: "load",
          timeout: 60_000
        )
      else
        page.set_content(html_content, wait_until: "load", timeout: TIMEOUT_CHARGEMENT)
        page.wait_for_network_idle(concurrency: 2, timeout: TIMEOUT_CHARGEMENT)
      end
      pause_pdf if Pdf::Browser.debug_mode?
      page
    ensure
      journalise_requetes(compteur)
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
