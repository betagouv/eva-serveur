ActiveAdmin.register Question do
  menu parent: 'Parcours', if: proc { current_compte.superadmin? }

  permit_params :libelle, :nom_technique, :intitule, :type,
                choix_attributes: %i[id intitule type_choix _destroy nom_technique]

  filter :libelle

  form partial: 'form'

  index do
    column :libelle
    column :created_at
    column :type
    actions
  end

  show do
    render partial: 'show'
  end
end
