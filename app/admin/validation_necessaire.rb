# frozen_string_literal: true

ActiveAdmin.register_page 'Validation nécessaire' do
  menu false

  content do
    render 'validation_necessaire'
  end

  controller do
    before_action :recupere_support

    def recupere_support
      @support = Compte.find_by(email: Eva::EMAIL_SUPPORT)
    end
  end
end
