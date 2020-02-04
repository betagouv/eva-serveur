# frozen_string_literal: true

module Restitution
  class AvecEntrainement < Base
    EVENEMENT = {
      DEMARRAGE: 'demarrage'
    }.freeze

    def temps_entrainement
      evenements_entrainement.last.date - evenements_entrainement.first.date
    end

    def demarrage
      @demarrage ||= MetriquesHelper.premier_evenement_du_nom(evenements, EVENEMENT[:DEMARRAGE])
    end

    def evenements_entrainement
      @evenements_entrainement ||= evenements.take_while do |evenement|
        evenement.nom != EVENEMENT[:DEMARRAGE]
      end
    end

    def evenements_situation
      @evenements_situation ||= evenements - evenements_entrainement
    end
  end
end
