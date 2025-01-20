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

        evenements_groupes = @evenements.groupes_par_questions
        evenements_groupes.each_with_object({}) do |(question, evenements), result|
          temps_de_reponse = Restitution::MetriquesHelper.temps_entre_couples(evenements).first
          result[question] = formate_duree(temps_de_reponse)
        end
      end
    end
  end
end
