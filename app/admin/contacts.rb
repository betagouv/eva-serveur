# frozen_string_literal: true

ActiveAdmin.register Contact do
  actions :index

  index do
    column :nom
    column :email
    column :saisi_par
    column :structure
  end
end
