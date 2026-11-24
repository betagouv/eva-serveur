module Campagnes
  class FiltresListe
    def initialize(parametres, compte)
      @parametres = parametres.presence || {}
      @compte = compte
    end

    def recherche
      @parametres[:recherche]
    end

    def situations
      Array(@parametres[:situations_configurations_situation_id_in]).compact_blank
    end

    def options_situations
      Situation.order(:libelle).pluck(:libelle, :id)
    end

    def creation
      @creation ||= Filtres::Periode.new(@parametres, :created_at)
    end

    def compte_choisi
      @compte_choisi ||= Filtres::Choix.new(@parametres, :compte_id_eq, Compte)
    end

    def filtre_structure?
      @compte.anlci? || @compte.administratif?
    end

    def structure
      @structure ||= Filtres::Choix.new(@parametres, :compte_structure_id_eq, StructureLocale)
    end
  end
end
