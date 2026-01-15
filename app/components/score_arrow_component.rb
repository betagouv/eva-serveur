class ScoreArrowComponent < ViewComponent::Base
  def initialize(score:, theme: :color, active: false)
    @score = score.to_s.upcase
    @theme = theme.to_sym
    @active = active
  end

  def css_classes
    [
      "score-fleche",
      "score-fleche--#{@theme}",
      "score-fleche--#{score_class}",
      active_class
    ].join(" ")
  end

  def active?
    @active
  end

  private

  def score_class
    @score.downcase
  end

  def active_class
    active? ? "score-fleche--active" : "score-fleche--inactive"
  end
end
