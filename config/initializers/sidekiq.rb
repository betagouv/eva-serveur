require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Sidekiq.configure_server do |config|
  config.logger = Sidekiq::Logger.new($stdout)
end
