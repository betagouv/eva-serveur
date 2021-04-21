# frozen_string_literal: true

module CampagneHelper
  def traduction_modele_parcours_campagne(modele_parcours)
    I18n.t(
      "activerecord.attributes.campagne.modele_parcours.#{modele_parcours}"
    )
  end

  def collection_modeles_parcours(situations)
    Campagne::PARCOURS.keys.map do |modele_parcours|
      [
        label_modele_parcours(modele_parcours, situations),
        modele_parcours
      ]
    end
  end

  def label_modele_parcours(modele_parcours, situations)
    render partial: 'components/input_choix_parcours',
           locals: {
             modele_parcours: modele_parcours,
             situations: situations
           }
  end
end
