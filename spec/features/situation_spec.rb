# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Situation', type: :feature do
  before { se_connecter_comme_administrateur }
  let!(:tri) { create :situation_tri, libelle: 'Situation Tri' }

  describe 'index' do
    before { visit admin_situations_path }
    it { expect(page).to have_content 'Situation Tri' }
  end

  describe 'création' do
    before do
      visit new_admin_situation_path
      fill_in :situation_libelle, with: 'Inventaire'
      fill_in :situation_nom_technique, with: 'inventaire'
    end

    it { expect { click_on 'Créer' }.to(change { Situation.count }) }
  end

  describe 'recalcule_metriques' do
    let(:evaluation) { create :evaluation }
    let!(:partie) do
      create :partie,
             evaluation: evaluation,
             situation: tri,
             metriques: { test: 'test' }
    end

    before { visit admin_situation_path(tri) }

    it {
      expect_any_instance_of(Partie).to receive(:persiste_restitution)
      click_on 'Recalcule les métriques'
    }
  end
end
