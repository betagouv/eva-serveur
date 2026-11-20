module Filtres
  class BarreRechercheComponent < ViewComponent::Base
    attr_reader :champ, :valeur

    def initialize(champ:, libelle:, valeur: nil)
      @champ = champ
      @libelle = libelle
      @valeur = valeur
    end
  end
end
