# frozen_string_literal: true

class ChiffreCleComponent < ViewComponent::Base
  def initialize(palier:, chiffre:, prefixe: nil, suffixe: nil)
    @palier = palier
    @chiffre = chiffre
    @prefixe = prefixe
    @suffixe = suffixe
  end
end
