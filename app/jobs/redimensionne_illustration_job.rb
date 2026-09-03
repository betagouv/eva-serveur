class RedimensionneIllustrationJob < ApplicationJob
  include Sidekiq::Throttled::Job

  queue_as :default

  sidekiq_throttle concurrency: { limit: 1 }

  def perform(question)
    question.illustration.variant(:defaut).processed
  end
end
