# frozen_string_literal: true

class EvaProScoreItemComponent < ViewComponent::Base
  LETTERS = %w[A B C D].freeze

  def initialize(letter:, active: false)
    @letter = letter.to_s.upcase
    @active = active
    raise ArgumentError, "letter must be A, B, C or D" unless LETTERS.include?(@letter)
  end

  def letter
    @letter
  end

  def active?
    @active
  end

  def css_classes
    classes = [ "eva-pro-score-item", "eva-pro-score-item--#{letter.downcase}" ]
    classes << "eva-pro-score-item--active" if active?
    classes.join(" ")
  end
end
