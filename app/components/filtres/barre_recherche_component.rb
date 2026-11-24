module Filtres
  class BarreRechercheComponent < ViewComponent::Base
    def initialize(champ:, libelle:, valeur: nil)
      @champ = champ
      @libelle = libelle
      @valeur = valeur
    end
  end
end
