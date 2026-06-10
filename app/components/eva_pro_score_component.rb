# frozen_string_literal: true

class EvaProScoreComponent < ViewComponent::Base
  LETTERS = %w[A B C D].freeze

  def initialize(score:)
    @active_letter = Evaluations::DiagnosticPro::SCORE_TO_LETTRE.fetch(score.to_s, score)
    raise ArgumentError,
"active_letter must be A, B, C or D" unless LETTERS.include?(@active_letter)
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
