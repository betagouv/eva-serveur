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
      [ label_option_personnalisation(situation), situation ]
    end
  end

  def collection_types_programme
    ParcoursType.types_programmes_eva.map do |type_programme|
      [ label_type_programme(type_programme), type_programme ]
    end
  end

  def label_parcours_type(parcours_type)
    render partial: "components/input_choix_parcours",
           locals: { parcours_type: parcours_type }
  end

  def label_option_personnalisation(situation)
    render partial: "components/input_option_personnalisation",
           locals: { situation: situation }
  end

  def label_type_programme(programme)
    render partial: "components/input_type_programme",
           locals: { programme: programme }
  end

  def url_campagne(campagne)
    base_url = URL_CLIENT
    base_url = URL_EVA_ENTREPRISES if campagne.parcours_type&.diagnostic_entreprise?
    Addressable::URI.escape("#{base_url}?code=#{campagne.code}")
  end

  def parcours_type_libelle(campagne)
    if campagne.parcours_type.nil?
      I18n.t("components.card_parcours_type.parcours_personnalise.libelle")
    else
      campagne.parcours_type.libelle
    end
  end
end
