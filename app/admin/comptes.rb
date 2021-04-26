# frozen_string_literal: true

ActiveAdmin.register Compte do
  permit_params :email, :password, :password_confirmation, :role, :structure_id,
                :statut_validation, :prenom, :nom, :telephone

  includes :structure

  index do
    column :prenom
    column :nom
    column :email
    column :telephone
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
      f.input :telephone
      if can? :manage, Compte
        f.input :role, as: :select, collection: %w[administrateur organisation]
        f.input :structure
      else
        f.input :structure_id, as: :hidden, input_html: { value: current_compte.structure_id }
      end
      f.input :statut_validation, as: :radio
      if peut_modifier_mot_de_passe?
        f.input :password, hint: resource.persisted? ? t('.aide_mot_de_passe') : ''
        f.input :password_confirmation
      end
    end
    f.actions
  end

  controller do
    helper_method :peut_modifier_mot_de_passe?

    def update_resource(object, attributes)
      update_method = if attributes.first[:password].present?
                        :update
                      else
                        :update_without_password
                      end
      object.send(update_method, *attributes)
    end

    def peut_modifier_mot_de_passe?
      resource.new_record? ||
        resource == current_compte ||
        can?(:manage, Compte)
    end
  end

  show do
    render 'show'
  end
end
