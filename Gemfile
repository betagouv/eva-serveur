ruby File.read(File.dirname(__FILE__) + "/.tool-versions")[/ruby \K.+/] || fail
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 7.2.0"
# Use Puma as the app server
gem "puma", "~> 6.0"

gem "sass-rails", ">= 6"
# Reduces boot times through caching; required in config/boot.rb
gem "activeadmin", "~> 3.2.5"
gem "activeadmin_addons"
gem "activeadmin_reorderable"
gem "activeadmin-xls", "~> 3.0.0"
gem "activestorage-validator", "~> 0.4.0"
gem "acts_as_list"
gem "addressable"
gem "ancestry", "~> 4.3"
gem "auto_strip_attributes", "~> 2.6"
gem "bootsnap", ">= 1.1.0", require: false
gem "bootstrap", "~> 4.3", ">= 4.3.1"
gem "cancancan"
gem "chartkick"
gem "coffee-rails"
gem "descriptive_statistics", "~> 2.4.0", require: "descriptive_statistics/safe"
gem "device_detector"
gem "devise"
gem "devise-i18n"
gem "down"
gem "dsfr-assets", "~> 1.13"
gem "dsfr-view-components", "~> 2.0"
gem "ffaker"
gem "geocoder"
gem "groupdate"
gem "health_check"
gem "i18n-js", "~> 3.9.0"
gem "image_processing"
gem "inline_svg"
gem "jbuilder"
gem "jquery-rails"
gem "jwt", "~> 2.6"
gem "kaminari-i18n"
gem "mailjet"
gem "paranoia"
gem "pg", "~> 1.0"
gem "rack-cors", require: "rack/cors"
gem "rails-i18n"
gem "recaptcha", "~> 5.16"
gem "recipient_interceptor"
gem "redcarpet"
gem "redis"
gem "rollbar"
gem "rubyzip"
gem "sidekiq", "< 8"
gem "sidekiq-scheduler"
gem "spreadsheet"
gem "sprockets-rails"
gem "truemail"
gem "typhoeus"
gem "view_component"
gem "web-console", group: :development

# PDF
gem "puppeteer-ruby"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

source "https://rails-assets.org" do
  gem "rails-assets-clipboard"
end

group :development, :test do
  gem "bullet"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri windows]
  gem "listen", "~> 3.2"
  gem "rspec_junit_formatter", "~> 0.4.1"
  gem "rspec-rails"
  gem "rubocop", require: false
  gem "rubocop-erb", require: false
  gem "rubocop-packaging", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rails-accessibility", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rspec", require: false
end

group :development do
  gem "foreman"
  gem "guard-rspec", require: false
  gem "guard-rubocop"
  gem "letter_opener"
  gem "rails-erd"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring", "~> 3.0"
  gem "spring-commands-rspec"

  gem "ruby-lsp", "~> 0.22.1"
  gem "ruby-lsp-rails", "~> 0.3.27"
end

group :test do
  gem "capybara"
  gem "factory_bot_rails"
  gem "launchy"
  gem "mutex_m"
  gem "pdf-reader"
  gem "shoulda-matchers"
  gem "timecop"
  gem "webmock"
end

group :production do
  gem "aws-sdk-s3", require: false
end
