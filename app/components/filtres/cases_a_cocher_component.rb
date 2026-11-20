module Filtres
  class CasesACocherComponent < ViewComponent::Base
    def initialize(champ:, libelle:, options:, valeurs: [])
      @champ = champ
      @libelle = libelle
      @options = options
      @valeurs = Array(valeurs).map(&:to_s)
    end

    def identifiant(valeur)
      "q_#{@champ}_#{valeur}"
    end

    def cochee?(valeur)
      @valeurs.include?(valeur.to_s)
    end
  end
end
