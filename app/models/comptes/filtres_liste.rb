module Comptes
  class FiltresListe
    attr_reader :activation

    def initialize(parametres, compte, gestion:, activation:)
      @parametres = parametres.presence || {}
      @compte = compte
      @gestion = gestion
      @activation = activation
    end

    def recherche
      @parametres[:recherche]
    end

    def statuts_validation
      Array(@parametres[:statut_validation_in]).compact_blank
    end

    def options_statuts_validation
      Compte.statuts_validation.map do |statut, valeur|
        [ Compte.human_enum_name(:statut_validation, statut), valeur ]
      end
    end

    def roles
      Array(@parametres[:role_in]).compact_blank
    end

    def creation
      @creation ||= Filtres::Periode.new(@parametres, :created_at)
    end

    def filtre_structure?
      @compte.anlci? || @compte.administratif?
    end

    def structure
      @structure ||= Filtres::Choix.new(@parametres, :structure_id_eq, Structure)
    end

    def filtres_gestion?
      @gestion
    end

    def criteres_structure?
      filtre_structure? || filtres_gestion?
    end

    def type_structure
      @parametres[:structure_type_structure_eq]
    end

    def region
      @parametres[:structure_region_eq]
    end

    def options_regions
      Structure.regions
    end

    def options_activation(nombres)
      Structures::Activation.options(nombres)
    end
  end
end
