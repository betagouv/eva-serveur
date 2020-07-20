# frozen_string_literal: true

ActiveAdmin.register Contact do
  actions :index, :create
  permit_params :email, :nom, :compte_id

  index do
    column :nom
    column :email
    column :saisi_par
    column :structure
  end

  controller do
    def create
      params[:contact][:compte_id] ||= current_compte.id
      create! { admin_root_path }
    end
  end
end
