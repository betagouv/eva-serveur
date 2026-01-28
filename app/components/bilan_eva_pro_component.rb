# frozen_string_literal: true

class BilanEvaProComponent < ViewComponent::Base
  include MarkdownHelper

  PALIERS = {
    "A - Très bon" => "a-tres-bon",
    "B - Bon" => "b-bon",
    "C - Moyen" => "c-moyen",
    "D - Mauvais" => "d-mauvais"
  }.freeze

  def initialize(palier:)
    @palier = palier
  end

  def palier
    @palier
  end

  def palier_css_class
    PALIERS[palier]
  end
end
