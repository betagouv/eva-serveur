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

    before do
      allow(FabriqueRestitution).to receive(:instancie).with(partie.id).and_return restitution
      allow(FabriqueRestitution).to receive(:restitution_globale)
        .with(evaluation)
        .and_return restitution_globale
      visit admin_situation_path(tri)
    end

    context 'persiste les restitutions terminées' do
      let(:restitution_globale) { double }
      let(:restitution) { double(termine?: true) }

      it do
        expect(restitution).to receive(:persiste)
        expect(restitution_globale).to receive(:persiste)
        click_on 'Recalcule les métriques'
      end
    end

    context 'ignore les restitutions non terminees' do
      let(:restitution_globale) { double }
      let(:restitution) { double(termine?: false) }

      it do
        expect(restitution).to_not receive(:persiste)
        expect(restitution_globale).to_not receive(:persiste)
        click_on 'Recalcule les métriques'
      end
    end
  end
end
