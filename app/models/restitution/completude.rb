# frozen_string_literal: true

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

    def competences_numeratie?
      @competences_numeratie ||= completude?(ids_situations_numeratie)
    end

    def competences_litteratie?
      @competences_litteratie ||= completude?(ids_situations_litteratie)
    end

    private

    def incomplete?
      (!competences_transversales? && !competences_de_base?) ||
        (!competences_de_base? && ids_situations_ct.empty?) ||
        (!competences_transversales? && ids_situations_cdb.empty?) ||
        (!competences_numeratie? && ids_situations_numeratie.empty?) ||
        (!competences_litteratie? && ids_situations_litteratie.empty?)
    end

    def ids_situations_ct
      @ids_situations_ct ||= SituationConfiguration.ids_situations(
        @evaluation.campagne_id,
        Situation::SITUATIONS_COMPETENCES_TRANSVERSALES
      )
    end

    def ids_situations_cdb
      @ids_situations_cdb ||= SituationConfiguration.ids_situations(
        @evaluation.campagne_id,
        Situation::SITUATIONS_DIAGNOSTIC
      )
    end

    def ids_situations_numeratie
      @ids_situations_numeratie ||= SituationConfiguration.ids_situations(
        @evaluation.campagne_id,
        Situation::SITUATIONS_NUMERATIE
      )
    end

    def ids_situations_litteratie
      @ids_situations_lietteratie ||= SituationConfiguration.ids_situations(
        @evaluation.campagne_id,
        Situation::SITUATIONS_LITTERATIE
      )
    end

    def completude?(situation_ids)
      situation_ids.all? do |situation_id|
        @restitutions.select { |r| r.situation.id == situation_id }.any?(&:termine?)
      end
    end
  end
end
