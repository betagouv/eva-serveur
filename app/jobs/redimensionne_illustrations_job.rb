# frozen_string_literal: true

class RedimensionneIllustrationsJob < ApplicationJob
  queue_as :default

  def perform
    Question.find_each do |question|
      next unless question.illustration.attached?

      question.illustration.variant(:defaut).processed
    end
  end
end
