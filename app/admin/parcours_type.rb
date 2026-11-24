ActiveAdmin.register ParcoursType do
  liste_dsfr

  permit_params :libelle, :actif, :position, :nom_technique,
                :duree_moyenne, :description, :type_de_programme,
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  filter :libelle, filters: [ :contains_unaccent, :eq ]
  filter :nom_technique
  filter :type_de_programme, as: :select
  filter :description, filters: [ :contains_unaccent, :eq ]
  filter :created_at

  form partial: "form"

  show do
    render partial: "show"
  end
end
