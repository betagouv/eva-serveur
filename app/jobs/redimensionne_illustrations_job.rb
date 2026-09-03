class RedimensionneIllustrationsJob < ApplicationJob
  queue_as :default

  def perform
    Question.find_each do |question|
      next unless question.illustration.attached?

      RedimensionneIllustrationJob.perform_later(question)
    end
  end
end
