# frozen_string_literal: true

ActiveAdmin.register Question do
  permit_params :intitule, choix_attributes: %i[id intitule type_choix _destroy]

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :intitule
      f.has_many :choix, allow_destroy: true do |c|
        c.input :id, as: :hidden
        c.input :intitule
        c.input :type_choix
      end
    end
    f.actions
  end

  show do
    render partial: 'show'
  end
end
