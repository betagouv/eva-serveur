# frozen_string_literal: true

require 'rails_helper'

describe 'Session', type: :feature do
  describe "Quand mon compte n'est pas confirmé" do
    context "Quand l'inscription est supérieure à 2 ans" do
      let!(:compte_non_confirme) do
        compte = create :compte, confirmed_at: nil
        compte.update(confirmation_sent_at: 3.years.ago)
        compte
      end

      it 'redirige vers la page de confirmation' do
        connecte(compte_non_confirme)
        expect(page).to have_current_path(new_compte_confirmation_path)
      end
    end

    context "Quand l'inscription est inférieure à 2 ans" do
      let!(:compte_non_confirme) do
        create :compte, confirmed_at: nil, confirmation_sent_at: Time.current
      end

      it 'redirige vers le tableau de bord' do
        connecte(compte_non_confirme)
        expect(page).to have_current_path(admin_dashboard_path)
      end
    end
  end
end
