# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Mise En Action', type: :feature do
  before { se_connecter_comme_administrateur }

  describe 'index' do
    let!(:mise_en_action) { create :mise_en_action, type_recommandation: :formation }
    before { visit admin_mises_en_action_path }
    it { expect(page).to have_content MiseEnAction.humanized_type_recommandation(:formation) }
  end

  describe 'création' do
    before do
      visit new_admin_mise_en_action_path
      within '#mise_en_action_elements_decouverts_input' do
        choose 'Non'
      end
      fill_in :mise_en_action_precision_elements_decouverts, with: 'Précisions éléments découverts'
      within '#mise_en_action_recommandations_candidat_input' do
        choose 'Oui'
      end
      select 'Ateliers ou prestation'
      fill_in :mise_en_action_precision_recommandation, with: 'Précisions recommandation'
      fill_in :mise_en_action_elements_facilitation_recommandation, with: 'Éléments faciliation '
    end

    it { expect { click_on 'Créer' }.to(change { MiseEnAction.count }) }
  end
end
