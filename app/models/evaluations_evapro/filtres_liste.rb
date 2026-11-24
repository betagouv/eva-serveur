module EvaluationsEvapro
  class FiltresListe
    def initialize(parametres, compte)
      @parametres = parametres.presence || {}
      @compte = compte
    end

    def recherche
      @parametres[:recherche]
    end

    def debut
      @debut ||= Filtres::Periode.new(@parametres, :debutee_le)
    end

    def filtre_structure?
      @compte.anlci? || @compte.administratif?
    end

    def structure
      @structure ||= Filtres::Choix.new(@parametres, :campagne_compte_structure_id_eq,
StructureLocale)
    end
  end
end
