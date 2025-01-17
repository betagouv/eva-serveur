# frozen_string_literal: true

module Restitution
  module Metriques
    class TempsPasseParQuestion
      include ApplicationHelper

      def initialize(evenements)
        @evenements = evenements
      end

      def calculer
        return if @evenements.empty?

        evenements_groupes = @evenements.groupees_par_questions
        evenements_groupes.each_with_object({}) do |(question, evenements), result|
          temps_total = calcul_temps_total(evenements)
          result[question] = formate_duree(temps_total)
        end
      end

      private

      def calcul_temps_total(evenements)
        return unless evenements.size >= 2

        Restitution::MetriquesHelper.temps_entre_couples(evenements)&.first || 0
      end
    end
  end
end
