module CampagneHelper
  def actions_campagne
    [
      { label: t("admin.campagnes.index.voir"), type: :read, url: :admin_campagne_path },
      { label: t("admin.campagnes.index.modifier"), type: :edit, url: :edit_admin_campagne_path },
      { label: t("admin.campagnes.index.supprimer"), type: :destroy,
        url: :admin_campagne_path, method: :delete,
        data: { confirm: t("admin.campagnes.index.confirmation_suppression") } }
    ]
  end

  def collection_parcours_type(liste_parcours_type)
    liste_parcours_type.map do |parcours_type|
      [
        label_parcours_type(parcours_type),
        parcours_type.id
      ]
    end
  end

  def collection_options_personnalisation
    Campagne::PERSONNALISATION.map do |option|
      [ label_option_personnalisation(option), option ]
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

  def label_option_personnalisation(option)
    render partial: "components/input_option_personnalisation",
           locals: { option: option }
  end

  def label_type_programme(programme)
    render partial: "components/input_type_programme",
           locals: { programme: programme }
  end

  def parcours_type_libelle(campagne)
    if campagne.parcours_type.nil?
      I18n.t("components.card_parcours_type.parcours_personnalise.libelle")
    else
      campagne.parcours_type.libelle
    end
  end

  def parcours_type_description(campagne)
    if campagne.parcours_type.nil?
      ""
    else
      campagne.parcours_type.description
    end
  end
end
