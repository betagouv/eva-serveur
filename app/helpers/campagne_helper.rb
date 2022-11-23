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

  def collection_options_personnalisation
    Campagne::PERSONNALISATION.map do |situation|
      [label_option_personnalisation(situation), situation]
    end
  end

  def collection_types_programme
    Campagne::TYPES_PROGRAMME.map do |type_programme|
      [label_type_programme(type_programme), type_programme]
    end
  end

  def label_parcours_type(parcours_type)
    render partial: 'components/input_choix_parcours',
           locals: { parcours_type: parcours_type }
  end

  def label_option_personnalisation(situation)
    render partial: 'components/input_option_personnalisation',
           locals: { situation: situation }
  end

  def label_type_programme(programme)
    render partial: 'components/input_type_programme',
           locals: { programme: programme }
  end

  def url_campagne(code)
    Addressable::URI.escape("#{URL_CLIENT}?code=#{code}")
  end

  def lien_campagne(campagne)
    url = url_campagne(campagne.code)
    link_to url, url, target: '_blank', rel: 'noopener'
  end
end
