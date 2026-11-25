module Beneficiaires
  class FiltresListe
    def initialize(parametres, compte)
      @parametres = parametres.presence || {}
      @compte = compte
    end

    def recherche
      @parametres[:recherche]
    end

    def statuts
      Array(@parametres[:statut_suivi_in]).compact_blank
    end

    def options_statuts
      EvaluationsEva::StatutSuivi::STATUTS_FILTRE.map do |statut|
        [ I18n.t("statut_suivi.#{statut}"), statut ]
      end
    end

    def creation
      @creation ||= Filtres::Periode.new(@parametres, :created_at)
    end

    def campagne
      @campagne ||= Filtres::Choix.new(@parametres, :evaluations_campagne_id_eq, Campagne)
    end

    def filtre_structure?
      @compte.anlci? || @compte.administratif?
    end

    def structure
      @structure ||= Filtres::Choix.new(@parametres, :evaluations_campagne_compte_structure_id_eq,
Structure)
    end
  end
end
