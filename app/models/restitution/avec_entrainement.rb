module Restitution
  class AvecEntrainement < Base
    def demarrage
      @demarrage ||= Restitution::MetriquesHelper.premier_evenement_du_nom(evenements, :DEMARRAGE)
    end

    def evenements_entrainement
      @evenements_entrainement ||= evenements.take_while do |evenement|
        evenement.nom != Restitution::MetriquesHelper::EVENEMENT[:DEMARRAGE]
      end
    end

    def evenements_situation
      @evenements_situation ||= evenements - evenements_entrainement
    end
  end
end
