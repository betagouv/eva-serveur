# frozen_string_literal: true

module Restitution
  module Illettrisme
    class TempsReponses
      def calcule(evenements, metacompetence)
        Restitution::MetriquesHelper.temps_questions(evenements) do |evenement|
          evenement.metacompetence == metacompetence
        end
      end
    end
  end
end
