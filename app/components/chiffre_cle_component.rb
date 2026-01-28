# frozen_string_literal: true

class ChiffreCleComponent < ViewComponent::Base
  PALIERS = {
    "A - Très bon" => "a-tres-bon",
    "B - Bon" => "b-bon",
    "C - Moyen" => "c-moyen",
    "D - Mauvais" => "d-mauvais"
  }.freeze

  def initialize(palier:, chiffre:, prefixe: nil, suffixe: nil)
    @palier = PALIERS[palier]
    @chiffre = chiffre
    @prefixe = prefixe
    @suffixe = suffixe
  end
end
