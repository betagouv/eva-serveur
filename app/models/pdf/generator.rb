module Pdf
  class Generator
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
      compteur = { locales: 0, reseau: 0 }
      page = browser.new_page
      page.viewport = Pdf::Browser::A4_VIEWPORT
      compteur = intercepte_assets_locaux(page)

      if Rails.env.development?
        page.set_content(
          html_content,
          wait_until: "load",
          timeout: 60_000
        )
      else
        page.set_content(html_content, wait_until: "load")
        page.wait_for_network_idle(concurrency: 2)
      end
      pause_pdf if Pdf::Browser.debug_mode?
      page
    ensure
      Rails.logger.info(
        "PDF: #{compteur[:locales]} requetes locales, #{compteur[:reseau]} requetes reseau"
      )
    end

    # Sert les assets de l'application (CSS, JS, SVG) directement depuis le
    # disque plutot que par un aller-retour HTTP vers notre propre domaine,
    # pour ne pas dependre de la charge du dyno pendant la generation du PDF.
    def intercepte_assets_locaux(page)
      compteur = { locales: 0, reseau: 0 }
      origine = "#{ENV['PROTOCOLE_SERVEUR']}://#{ENV['HOTE_SERVEUR']}"
      page.request_interception = true
      page.on("request") do |requete|
        compteur[repond_avec_asset_local(requete, origine) ? :locales : :reseau] += 1
      end
      compteur
    end

    def repond_avec_asset_local(requete, origine)
      chemin = chemin_asset_local(requete.url, origine)
      unless chemin
        requete.continue
        return false
      end

      requete.respond(
        status: 200,
        content_type: Rack::Mime.mime_type(chemin.extname),
        body: File.binread(chemin)
      )
      true
    rescue
      requete.continue
      false
    end

    def chemin_asset_local(url, origine)
      return nil unless url.start_with?(origine)

      racine = Rails.public_path.expand_path
      chemin = racine.join(URI(url).path.delete_prefix("/")).expand_path
      chemin if chemin.to_s.start_with?("#{racine}/") && File.file?(chemin)
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
