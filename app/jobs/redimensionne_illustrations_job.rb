# frozen_string_literal: true

class RedimensionneIllustrationsJob < ApplicationJob
  queue_as :default

  def perform
    Question.find_each do |question|
      next unless question.illustration.attached?

      question.illustration.variant(resize_to_limit: [1008, 566]).processed
    end
  end
end
