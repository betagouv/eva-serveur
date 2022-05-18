# frozen_string_literal: true

ruby '3.0.3'
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.0.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'

gem 'sass-rails', '>= 6'
# Reduces boot times through caching; required in config/boot.rb
gem 'activeadmin', git: 'https://github.com/shanser/activeadmin',
                   branch: '7084-renders-action-items-only-when-authorized'
gem 'activeadmin_addons'
gem 'activeadmin_reorderable'
gem 'activeadmin-xls', git: 'https://github.com/shanser/activeadmin-xls',
                       branch: 'autoload'
gem 'acts_as_list'
gem 'addressable'
gem 'auto_strip_attributes', '~> 2.6'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootstrap', '~> 4.3', '>= 4.3.1'
gem 'cancancan'
gem 'chartkick'
gem 'coffee-rails'
gem 'descriptive_statistics', '~> 2.4.0', require: 'descriptive_statistics/safe'
gem 'devise'
gem 'devise-i18n'
gem 'ffaker'
gem 'geocoder'
gem 'groupdate'
gem 'inline_svg'
gem 'jbuilder'
gem 'jquery-rails'
gem 'kaminari-i18n'
gem 'mailjet'
gem 'mini_racer', '~> 0.4.0'
gem 'pg', '~> 1.0'
gem 'rack-cors', require: 'rack/cors'
gem 'rails-i18n'
gem 'recipient_interceptor'
gem 'redcarpet'
gem 'redis'
gem 'rollbar'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'sprockets-rails'
gem 'truemail'
gem 'web-console', group: :development
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary', '~> 0.12.3.1'

source 'https://rails-assets.org' do
  gem 'rails-assets-clipboard'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'listen', '~> 3.2'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'rspec-rails', '6.0.0.rc1'
  gem 'rubocop', require: false
  gem 'rubocop-packaging', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'foreman'
  gem 'guard-rspec', require: false
  gem 'guard-rubocop'
  gem 'letter_opener'
  gem 'rails-erd'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 3.0'
  gem 'spring-commands-rspec'
  gem 'tarteaucitron'
end

group :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'pdf-reader'
  gem 'shoulda-matchers'
end

group :production do
  gem 'aws-sdk-s3', require: false
end
