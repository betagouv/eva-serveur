# frozen_string_literal: true

require 'puppeteer-ruby'

class Html2Pdf
  def genere_pdf_depuis_url(url)
    Puppeteer.launch(**puppeteer_options) do |browser|
      page = browser.new_page
      page.goto(url, wait_until: 'domcontentloaded')
      Rails.logger.debug 'screenshot start'
      page.screenshot(path: 'YusukeIwaki.png')
      Rails.logger.debug 'screenshot end'
      page.pdf(**pdf_options)
      filename
    end
  rescue Puppeteer::Connection::ProtocolError => e
    Rails.logger.error(e.message)
    false
  end

  def genere_pdf_depuis_html(html_content)
    Puppeteer.launch(**puppeteer_options) do |browser|
      page = browser.new_page
      page.viewport = Puppeteer::Viewport.new(width: 2160, height: 3840)

      # Set content using the provided HTML
      page.set_content(html_content, wait_until: 'domcontentloaded')
      page.screenshot(path: 'YusukeIwaki.png', full_page: true)

      puts "Appuyez sur Entrée pour fermer le navigateur..."
      gets # Attend une entrée utilisateur

      p pdf_options
      page.pdf(**pdf_options)
      filename # Return the filename so it can be used for file delivery
    end
  rescue Puppeteer::Connection::ProtocolError => e
    Rails.logger.error(e.message)
    false
  end

  private

  def puppeteer_options
    options = {
      headless: false, args: ['--no-sandbox', '--disable-setuid-sandbox']
    }
    options[:executable_path] = ENV['GOOGLE_CHROME_SHIM'] if ENV['GOOGLE_CHROME_SHIM']
    options
  end

  def pdf_options(format: 'A4', landscape: false)
    @pdf_options ||= {
      path: filename,
      print_background: true,
      format: format,
      landscape: landscape
    }
  end

  def filename
    @filename ||= begin
      dir_path = Rails.root.join('tmp/pdf')
      FileUtils.mkdir_p(dir_path)
      dir_path.join("document-#{SecureRandom.uuid}.pdf")
    end
  end
end
