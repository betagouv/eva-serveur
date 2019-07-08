# frozen_string_literal: true

ActiveAdmin.register Campagne do
  permit_params :libelle, :code
end
