module Filtres
  class Periode
    def initialize(parametres, champ)
      @parametres = parametres
      @champ = champ
    end

    def debut
      @parametres[:"#{@champ}_gteq_datetime"]
    end

    def fin
      @parametres[:"#{@champ}_lteq_datetime"]
    end

    def nombre_bornes
      [ debut, fin ].count(&:present?)
    end
  end
end
