# frozen_string_literal: true

ActiveAdmin.register Contact do
  menu parent: 'Terrain'
  actions :index, :create

  permit_params :telephone, :email, :nom, :compte_id

  filter :compte_id,
         as: :search_select_filter,
         url: proc { admin_comptes_path },
         fields: %i[email nom prenom],
         display_name: 'display_name',
         label: 'Saisi par',
         minimum_input_length: 2,
         order_by: 'email_asc',
         if: proc { can? :manage, Compte }
  filter :nom
  filter :email
  filter :telephone
  filter :created_at

  index do
    column :nom
    column :email
    column :telephone
    column :saisi_par
    column :structure
    column :created_at
  end

  controller do
    def create
      params[:contact][:compte_id] ||= current_compte.id
      create! { admin_root_path }
    end
  end
end
