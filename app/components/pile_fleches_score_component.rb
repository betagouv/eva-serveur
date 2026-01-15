class PileFlechesScoreComponent < ViewComponent::Base
  SCORES = %w[a b c d].freeze

  def initialize(theme: :color, active_score: nil)
    @theme = theme.to_sym
    @active_score = active_score&.to_s&.downcase
  end

  def scores
    SCORES
  end

  def active_score?(score)
    @active_score == score
  end

  def wrapper_classes
    classes = [ "score-arrows-stack" ]
    classes << "score-arrows-stack--active-#{@active_score}" if @active_score.present?
    classes.join(" ")
  end
end
