# frozen_string_literal: true

ActiveAdmin.register_page 'Validation nécessaire' do
  menu false

  content do
    render 'validation_necessaire'
  end

  controller do
    skip_before_action :verifie_validation_necessaire
  end
end
