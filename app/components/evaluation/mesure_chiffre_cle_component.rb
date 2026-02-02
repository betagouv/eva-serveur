# frozen_string_literal: true

class Evaluation
  class MesureChiffreCleComponent < ViewComponent::Base
    def initialize(palier:, chiffre:, prefixe: nil, suffixe: nil, explications:)
      @palier = palier
      @chiffre = chiffre
      @prefixe = prefixe
      @suffixe = suffixe
      @explications = explications
    end

    private

    attr_reader :palier, :chiffre, :prefixe, :suffixe, :explications

    def texte
      explications[:texte]
    end

    def suite
      explications[:suite]
    end
  end
end
