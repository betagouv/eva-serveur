ActiveAdmin.register ParcoursType do
  menu parent: "Parcours", if: proc { can? :manage, Compte }

  permit_params :libelle, :actif, :position, :nom_technique,
                :duree_moyenne, :description, :type_de_programme,
                situations_configurations_attributes: %i[id situation_id questionnaire_id _destroy]

  filter :libelle, filters: [ :contains_unaccent, :eq ]
  filter :nom_technique
  filter :type_de_programme, as: :select
  filter :description, filters: [ :contains_unaccent, :eq ]
  filter :created_at

  form partial: "form"

  index do
    column :libelle do |pt|
      link_to pt.libelle, admin_parcours_type_path(pt)
    end
    column :actif
    column :position
    column :nom_technique
    column :type_de_programme
    column :created_at
    actions
  end

  show do
    render partial: "show"
  end
end
