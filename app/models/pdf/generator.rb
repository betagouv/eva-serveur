module Pdf
  class Generator
    def generate(html_content, filename: "document-#{SecureRandom.uuid}")
      browser = Pdf::Browser.instance

      page = prepare_page(browser, html_content)

      page.pdf(**pdf_options(filename: filename))
      page.close
      file_path(filename)
    rescue => e
      Rails.logger.error("Chromium crash: #{e.message}")
      Rollbar.error(e)
      page.close if page
      false
    end

    def self.generate(html_content)
      new.generate(html_content)
    end

    def prepare_page(browser, html_content)
      page = browser.new_page
      page.viewport = Pdf::Browser::A4_VIEWPORT
      page.set_content(html_content, wait_until: "networkidle2")
      pause_pdf if Pdf::Browser.debug_mode?
      page
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
