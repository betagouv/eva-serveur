module Filtres
  class RechercheComponent < ViewComponent::Base
    def initialize(champ:, libelle:, url:, champs_recherche:, valeur: nil, libelle_valeur: nil)
      @champ = champ
      @libelle = libelle
      @url = url
      @predicat = "#{champs_recherche.join("_or_")}_i_cont"
      @valeur = valeur
      @libelle_valeur = libelle_valeur
    end

    def identifiant
      "q_#{@champ}"
    end
  end
end
