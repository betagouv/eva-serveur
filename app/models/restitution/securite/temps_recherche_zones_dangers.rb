# frozen_string_literal: true

module Restitution
  class Securite
    class TempsRechercheZonesDangers
      attr_reader :evenements_situation

      def initialize(evenements_situation, _)
        @evenements_situation = evenements_situation
      end

      def calcule
        durees = {}
        Securite::ZONES_DANGER.each do |danger|
          duree = duree_recherche(danger)
          durees[danger] = duree if duree.present?
        end
        durees
      end

      private

      def duree_recherche(danger)
        date_evenement_precedent = nil
        evenements_situation.each do |e|
          if e.demarrage? || e.qualification_danger?
            date_evenement_precedent = e.date
          elsif e.donnees['danger'] == danger && e.ouverture_zone_danger?
            return e.date - date_evenement_precedent
          end
        end
        nil
      end
    end
  end
end
