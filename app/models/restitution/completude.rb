# frozen_string_literal: true

module Restitution
  class Completude
    def initialize(evaluation, restitutions)
      @evaluation = evaluation
      @restitutions = restitutions
    end

    def calcule
      return :incomplete if incomplete?
      return :competences_transversales_incompletes unless competence_transversale?
      return :competences_de_base_incompletes unless competences_de_base?

      :complete
    end

    def ids_situations(id_campagne, noms_techniques)
      SituationConfiguration.joins(:situation)
                            .where(campagne_id: id_campagne)
                            .where(situations: { nom_technique: noms_techniques })
                            .pluck(:situation_id)
    end

    private

    def incomplete?
      (!competence_transversale? && !competences_de_base?) ||
        (!competences_de_base? && ids_situations_ct.empty?) ||
        (!competence_transversale? && ids_situations_cdb.empty?)
    end

    def ids_situations_ct
      @ids_situations_ct ||= ids_situations(@evaluation.campagne_id,
                                            Evaluation::SITUATION_COMPETENCES_TRANSVERSALES)
    end

    def ids_situations_cdb
      @ids_situations_cdb ||= ids_situations(@evaluation.campagne_id,
                                             Evaluation::SITUATION_COMPETENCES_BASE)
    end

    def competence_transversale?
      @competence_transversale ||= completude?(ids_situations_ct)
    end

    def competences_de_base?
      @competences_de_base ||= completude?(ids_situations_cdb)
    end

    def completude?(situation_ids)
      situation_ids.all? do |situation_id|
        @restitutions.select { |r| r.situation.id == situation_id }.any?(&:termine?)
      end
    end
  end
end
