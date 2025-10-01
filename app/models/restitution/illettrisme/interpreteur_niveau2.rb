module Restitution
  module Illettrisme
    class InterpreteurNiveau2
      METACOMPETENCES = {
        litteratie: Restitution::ScoresNiveau1::METACOMPETENCES_LITTERATIE,
        numeratie: Restitution::ScoresNiveau1::METACOMPETENCES_NUMERATIE
      }.freeze

      def initialize(scores)
        @interpreteur_score = InterpreteurScores.new(scores)
      end

      def interpretations(categorie)
        @interpreteur_score.interpretations(METACOMPETENCES[categorie])
      end
    end
  end
end
