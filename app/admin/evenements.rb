# frozen_string_literal: true

ActiveAdmin.register Evenement do
  permit_params :type_evenement, :description
end
