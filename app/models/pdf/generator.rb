module Pdf
  class Generator
    def generate(html_content, output_path: nil)
      browser = Pdf::Browser.instance

      page = prepare_page(browser, html_content)

      page.pdf(**pdf_options)
      page.close
      filename
    rescue => e
      page.close if page
      raise e
    end

    def self.generate(html_content, output_path: nil)
      new.generate(html_content, output_path: nil)
    end

    def prepare_page(browser, html_content)
      page = browser.new_page
      page.viewport = Pdf::Browser::A4_VIEWPORT
      page.set_content(html_content, wait_until: "networkidle2")
      pause_pdf
      page
    end

    # Le mode debug permet d'ouvrir une page chrome pour visualiser le rendu
    # et inspecter l'html avant la transformation en PDF
    def pause_pdf
      return unless Pdf::Browser.debug_mode?

      Rails.logger.debug 'Appuyer sur la touche "Entrer" pour continuer le processus'
      gets # Attend que l'utilisateur appuie sur "Enter" (dans le terminal du serveur)
    end

    def pdf_options(format: "A4", landscape: false)
      @pdf_options ||= {
        path: filename,
        print_background: true,
        format: format,
        landscape: landscape,
        margin: { top: "0px", right: "0px", bottom: "0px", left: "0px" }
      }
    end

    def filename
      @filename ||= begin
        dir_path = Rails.root.join("tmp/pdf")
        FileUtils.mkdir_p(dir_path)
        dir_path.join("document-#{SecureRandom.uuid}.pdf")
      end
    end
  end
end
