# frozen_string_literal: true

ActiveAdmin.register Contact do
  actions :index, :create
  permit_params :telephone, :email, :nom, :compte_id

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
