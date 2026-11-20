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

    def compte_id
      @parametres[:compte_id_eq]
    end

    def compte_choisi
      return if compte_id.blank?

      @compte_choisi ||= Compte.find_by(id: compte_id)
    end

    def filtre_structure?
      @compte.anlci? || @compte.administratif?
    end

    def structure_id
      @parametres[:compte_structure_id_eq]
    end

    def structure
      return if structure_id.blank?

      @structure ||= StructureLocale.find_by(id: structure_id)
    end
  end
end
