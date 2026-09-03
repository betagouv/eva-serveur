class RedimensionneIllustrationJob < ApplicationJob
  queue_as :default

  def perform(question)
    question.illustration.variant(:defaut).processed
  end
end
