require "puppeteer"

module Pdf
  class Browser
    A4_VIEWPORT = Puppeteer::Viewport.new(width: 1008, height: 1488)
    A4_WINDOW_SIZE = "--window-size=1008,1488"

    def self.instance
      @browser ||= Puppeteer.launch(**puppeteer_options)
    end

    def self.puppeteer_options
      options = {
        headless: "new",
        args: [
          "--no-sandbox",
          "--disable-setuid-sandbox",
          "--disable-dev-shm-usage",
          "--disable-gpu",
          A4_WINDOW_SIZE
        ]
      }
      if debug_mode?
        options[:headless] = false
        options[:args] += [ "--auto-open-devtools-for-tabs" ]
      end
      options[:executable_path] = ENV["GOOGLE_CHROME_SHIM"] if ENV["GOOGLE_CHROME_SHIM"]
      options
    end

    def self.debug_mode?
      ENV["DEBUG_PDF"].present? && ENV["DEBUG_PDF"] == "true" && Rails.env.development?
    end
  end
end
