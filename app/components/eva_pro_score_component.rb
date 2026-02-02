# frozen_string_literal: true

class EvaProScoreComponent < ViewComponent::Base
  LETTERS = %w[A B C D].freeze

  def initialize(active_letter:)
    @active_letter = active_letter.to_s.upcase
    raise ArgumentError, "active_letter must be A, B, C or D" unless LETTERS.include?(@active_letter)
  end

  def items
    LETTERS.map do |letter|
      {
        letter:,
        active: letter == @active_letter
      }
    end
  end
end
