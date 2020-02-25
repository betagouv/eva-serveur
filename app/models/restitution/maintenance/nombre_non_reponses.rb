# frozen_string_literal: true

module Restitution
  class Maintenance
    class NombreNonReponses < Restitution::Metriques::Base
      def calcule(evenements_situation, _)
        evenements_situation.select(&:non_reponse?).count
      end
    end
  end
end
