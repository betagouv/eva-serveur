module EvaluationsEva
  class FiltresListe
    SCOPE_ILLETTRISME_POTENTIEL = "illettrisme_potentiel".freeze

    def initialize(parametres, compte, scope:)
      @parametres = parametres.presence || {}
      @compte = compte
      @scope = scope
    end

    def recherche
      @parametres[:recherche]
    end

    def statuts
      Array(@parametres[:statut_suivi_in]).compact_blank
    end

    def options_statuts
      StatutSuivi::STATUTS_FILTRE.map do |statut|
        [ I18n.t("statut_suivi.#{statut}"), statut ]
      end
    end

    def debut
      @debut ||= Filtres::Periode.new(@parametres, :debutee_le)
    end

    def illettrisme_potentiel?
      @scope.to_s == SCOPE_ILLETTRISME_POTENTIEL
    end

    def campagne
      @campagne ||= Filtres::Choix.new(@parametres, :campagne_id_eq, Campagne)
    end

    def responsable_suivi
      @responsable_suivi ||= Filtres::Choix.new(@parametres, :responsable_suivi_id_eq, Compte)
    end

    def filtre_structure?
      @compte.anlci? || @compte.administratif?
    end

    def structure
      @structure ||= Filtres::Choix.new(@parametres, :campagne_compte_structure_id_eq,
StructureLocale)
    end

    def filtre_statut?
      @compte.superadmin?
    end

    def statut
      @parametres[:statut_eq].presence
    end

    def options_statuts_evaluation
      EvaluationEva.statuts.map do |statut, valeur|
        [ EvaluationEva.human_enum_name(:statut, statut), valeur ]
      end
    end
  end
end
