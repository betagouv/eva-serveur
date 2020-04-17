# frozen_string_literal: true

module Restitution
  module Illettrisme
    class NombreBonnesReponses < Restitution::Metriques::Base
      def calcule(evenements, metacompetence)
        evenements.select do |evenement|
          evenement.metacompetence == metacompetence &&
            evenement.bonne_reponse?
        end.count
      end
    end
  end
end
