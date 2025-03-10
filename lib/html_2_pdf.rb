# frozen_string_literal: true

require 'puppeteer-ruby'

class Html2Pdf
  def genere_pdf_depuis_html(html_content)
    Puppeteer.launch(**puppeteer_options) do |browser|
      page = browser.new_page

      page.set_content(html_content, wait_until: 'networkidle2')

      page.pdf(**pdf_options)
      filename
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
      landscape: landscape,
      margin: { top: '0px', right: '0px', bottom: '0px', left: '0px' }
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
