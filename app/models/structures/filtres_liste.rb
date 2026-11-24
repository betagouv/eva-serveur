module Structures
  class FiltresListe
    attr_reader :activation

    def initialize(parametres, compte, activation:)
      @parametres = parametres.presence || {}
      @compte = compte
      @activation = activation
    end

    def recherche
      @parametres[:recherche]
    end

    def type_structure
      @parametres[:type_structure_eq]
    end

    def filtre_usage?
      @compte.anlci?
    end

    def usage
      @parametres[:usage_eq]
    end

    def region
      @parametres[:region_eq]
    end

    def options_regions
      Structure.regions
    end

    def creation
      @creation ||= Filtres::Periode.new(@parametres, :created_at)
    end

    def options_activation(nombres)
      Activation.options(nombres)
    end
  end
end
