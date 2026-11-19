require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--window-size=1400,1400')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Capybara 3.40.0 vide le stockage avec l'origine '*', que Chrome 158 refuse
# ("* is not a valid URL") : on cible l'origine du serveur de test.
module ViderStockageOrigineServeur
  private

  def execute_cdp(cmd, params = {})
    if cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'
      origine = Capybara.current_session.server&.base_url
      return unless origine

      params = params.merge(origin: origine)
    end
    super
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ViderStockageOrigineServeur)

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true, Threads: '1:1' }

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each, :js, type: :feature) do
    @original_asset_host = ActionController::Base.asset_host
    ActionController::Base.asset_host = nil
  end

  config.after(:each, :js, type: :feature) do
    ActionController::Base.asset_host = @original_asset_host
  end
end
