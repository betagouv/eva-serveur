module Restitution
  class Completude
    IMPACT_KEYS = %i[
      performance_collective
      agilite_organisationnelle
      securite_qualite
      mobilite_professionnelle
    ].freeze

    def initialize(evaluation, restitutions)
      @evaluation = evaluation
      @restitutions = restitutions
    end

    def calcule
      return calcule_completude_evapro if @evaluation.evapro?

      return :incomplete if incomplete?
      return :competences_transversales_incompletes unless competences_transversales?
      return :competences_de_base_incompletes unless competences_de_base?

      :complete
    end

    private

    def calcule_completude_evapro
      diag = derniere_restitution(Situation::DIAG_RISQUES_ENTREPRISE)
      impact = derniere_restitution(Situation::EVALUATION_IMPACT_GENERAL)

      return :incomplete if diag.blank? || impact.blank?

      diag_synthese = (diag.synthese || {}).with_indifferent_access
      impact_synthese = (impact.synthese || {}).with_indifferent_access

      risque_ok = diag_synthese[:pourcentage_risque].present?
      cout_ok = impact_synthese[:score_cout].present?
      impact_ok = IMPACT_KEYS.all? { |k| impact_synthese[k].present? }

      (risque_ok && cout_ok && impact_ok) ? :complete : :incomplete
    end

    def derniere_restitution(nom_technique)
      @restitutions.reverse.find do |r|
        r.situation.a_pour_nom_technique?(nom_technique)
      end
    end

    def competences_transversales?
      @competences_transversales ||= completude?(ids_situations_ct)
    end

    def competences_de_base?
      @competences_de_base ||= completude?(ids_situations_cdb)
    end

    def incomplete?
      (!competences_transversales? && !competences_de_base?) ||
        (!competences_de_base? && ids_situations_ct.empty?) ||
        (!competences_transversales? && ids_situations_cdb.empty?)
    end

    def ids_situations_ct
      @ids_situations_ct ||= SituationConfiguration.ids_situations(
        @evaluation.campagne_id,
        Evaluation::SITUATION_COMPETENCES_TRANSVERSALES
      )
    end

    def ids_situations_cdb
      @ids_situations_cdb ||= SituationConfiguration.ids_situations(
        @evaluation.campagne_id,
        Evaluation::SITUATION_COMPETENCES_BASE
      )
    end

    def completude?(situation_ids)
      situation_ids.all? do |situation_id|
        @restitutions.select { |r| r.situation.id == situation_id }.any?(&:termine?)
      end
    end
  end
end
