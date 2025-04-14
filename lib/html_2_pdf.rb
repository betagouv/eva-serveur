# frozen_string_literal: true

require "puppeteer-ruby"

class Html2Pdf
  A4_VIEWPORT = Puppeteer::Viewport.new(width: 1008, height: 1488)
  A4_WINDOW_SIZE = "--window-size=1920,1080"

  class << self
    def genere_pdf_depuis_html(html_content)
      Puppeteer.launch(**puppeteer_options) do |browser|
        page = prepare_page(browser, html_content)

        page.pdf(**pdf_options)
        filename
      end
    rescue Puppeteer::Connection::ProtocolError, Puppeteer::TimeoutError => e
      Rails.logger.error("Puppeteer : #{e.message}")
      Rollbar.error(e)
      false
    end

    private

    def prepare_page(browser, html_content)
      page = browser.new_page
      page.viewport = A4_VIEWPORT
      page.set_content(html_content, wait_until: "networkidle2")
      pause_pdf
      page
    end

    def debug_mode?
      ENV["DEBUG_PDF"].present? && Rails.env.development?
    end

    # Le mode debug permet d'ouvrir une page chrome pour visualiser le rendu
    # et inspecter l'html avant la transformation en PDF
    def pause_pdf
      return unless debug_mode?

      Rails.logger.debug 'Appuyer sur la touche "Entrer" pour continuer le processus'
      gets # Attend que l'utilisateur appuie sur "Enter" (dans le terminal du serveur)
    end

    def puppeteer_options
      options = {
        headless: true, args: [ "--no-sandbox", "--disable-setuid-sandbox", A4_WINDOW_SIZE ]
      }
      if debug_mode?
        options[:headless] = false
        options[:args] += [ "--auto-open-devtools-for-tabs" ]
      end
      options[:executable_path] = ENV["GOOGLE_CHROME_SHIM"] if ENV["GOOGLE_CHROME_SHIM"]
      options
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
