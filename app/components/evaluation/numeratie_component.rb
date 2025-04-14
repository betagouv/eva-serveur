# frozen_string_literal: true

class Evaluation
  class NumeratieComponent < ViewComponent::Base
    def initialize(restitution_globale:, place_du_marche:)
      @restitution_globale = restitution_globale
      @place_du_marche = place_du_marche
      @profil = place_du_marche ? place_du_marche.profil_numeratie : 'indetermine'
      @synthese = restitution_globale.synthese_positionnement_numeratie
      @sous_competences = place_du_marche&.competences_numeratie
    end

    def classes_panel
      'panel'
    end
  end
end
