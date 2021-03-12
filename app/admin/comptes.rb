# frozen_string_literal: true

ActiveAdmin.register Compte do
  permit_params :email, :password, :password_confirmation, :role, :structure_id,
                :statut_validation, :prenom, :nom

  includes :structure

  index do
    column :prenom
    column :nom
    column :email
    column :statut_validation
    if can? :manage, Compte
      column :role
      column :structure
      column :created_at
    end
    actions
  end

  filter :email
  filter :statut_validation,
         as: :select,
         collection: Compte.statuts_validation.map { |v, id|
                       [Compte.humanized_statut_validation(v), id]
                     }

  filter :structure, if: proc { can? :manage, Compte }
  filter :created_at

  form do |f|
    f.inputs do
      f.input :prenom
      f.input :nom
      f.input :email
      if can? :manage, Compte
        f.input :role, as: :select, collection: %w[administrateur organisation]
        f.input :structure
      else
        f.input :structure_id, as: :hidden, input_html: { value: current_compte.structure_id }
      end
      f.input :statut_validation, as: :radio
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  controller do
    def update_resource(object, attributes)
      update_method = if attributes.first[:password].present?
                        :update
                      else
                        :update_without_password
                      end
      object.send(update_method, *attributes)
    end
  end

  show do
    render 'show'
  end
end
