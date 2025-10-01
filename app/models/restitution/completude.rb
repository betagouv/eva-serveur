module Restitution
  class Completude
    def initialize(evaluation, restitutions)
      @evaluation = evaluation
      @restitutions = restitutions
    end

    def calcule
      return :incomplete if incomplete?
      return :competences_transversales_incompletes unless competences_transversales?
      return :competences_de_base_incompletes unless competences_de_base?

      :complete
    end

    def competences_transversales?
      @competences_transversales ||= completude?(ids_situations_ct)
    end

    def competences_de_base?
      @competences_de_base ||= completude?(ids_situations_cdb)
    end

    private

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
