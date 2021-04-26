# frozen_string_literal: true

module CampagneHelper
  def collection_parcours_type(liste_parcours_type)
    liste_parcours_type.map do |parcours_type|
      [
        label_parcours_type(parcours_type),
        parcours_type.id
      ]
    end
  end

  def label_parcours_type(parcours_type)
    render partial: 'components/input_choix_parcours',
           locals: { parcours_type: parcours_type }
  end
end
