module Restitution
  module Evapro
    class Completude
      def initialize(evaluation, restitutions)
        @evaluation = evaluation
        @restitutions = restitutions
      end

      def calcule
        complete? ? :complete : :incomplete
      end

      private

      def ids_situations_campagne
        SituationConfiguration.ids_situations(
          @evaluation.campagne_id,
          EvaluationEvapro::SITUATION_COMPETENCES_EVAPRO
        )
      end

      def complete?
        ids_situations_campagne.all? do |situation_id|
          @restitutions.select { |r| r.situation.id == situation_id }.any?(&:termine?)
        end
      end
    end
  end
end
