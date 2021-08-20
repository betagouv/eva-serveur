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

  def url_campagne(code)
    Addressable::URI.escape("#{URL_CLIENT}?code=#{code}")
  end

  def lien_campagne(campagne)
    url = url_campagne(campagne.code)
    link_to url, url, target: '_blank', rel: 'noopener'
  end
end
