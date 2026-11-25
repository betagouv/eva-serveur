module Referentiels
  class FiltresListe
    def initialize(parametres)
      @parametres = parametres.presence || {}
    end

    def valeur(predicat)
      @parametres[predicat].presence
    end

    def periode(champ)
      Filtres::Periode.new(@parametres, champ)
    end

    def choix(predicat, modele)
      Filtres::Choix.new(@parametres, predicat, modele)
    end
  end
end
