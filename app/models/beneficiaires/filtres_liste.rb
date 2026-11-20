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

    def creation_debut
      @parametres[:created_at_gteq_datetime]
    end

    def creation_fin
      @parametres[:created_at_lteq_datetime]
    end

    def nombre_bornes_creation
      [ creation_debut, creation_fin ].count(&:present?)
    end

    def campagne_id
      @parametres[:evaluations_campagne_id_eq]
    end

    def campagne
      return if campagne_id.blank?

      @campagne ||= Campagne.find_by(id: campagne_id)
    end

    def filtre_structure?
      @compte.anlci? || @compte.administratif?
    end

    def structure_id
      @parametres[:evaluations_campagne_compte_structure_id_eq]
    end

    def structure
      return if structure_id.blank?

      @structure ||= Structure.find_by(id: structure_id)
    end
  end
end
