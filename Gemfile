# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Reduces boot times through caching; required in config/boot.rb
gem 'activeadmin'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'devise'
gem 'pg', '~> 0.18'
gem 'rack-cors', require: 'rack/cors'
gem 'mini_racer', '~> 0.2.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails'
  gem 'rspec_junit_formatter', '~> 0.4.1'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'foreman'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  gem 'launchy'
  gem 'rubocop', require: false
  gem 'shoulda-matchers', '~> 3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
