# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evaluation', type: :feature do
  before(:each) { se_connecter_comme_organisation }

  context "en tant qu'organisation" do
    let(:compte_rouen) { create :compte, role: 'organisation' }
    let(:campagne_rouen) { create :campagne, compte: compte_rouen, libelle: 'Rouen 2019' }
    let!(:evaluation) { create :evaluation, campagne: campagne_rouen }
    let(:ma_campagne) do
      create :campagne, compte: Compte.first, libelle: 'Paris 2019', code: 'paris2019'
    end

    let!(:mon_evaluation) { create :evaluation, campagne: ma_campagne, created_at: 3.days.ago }
    let!(:mon_evaluation2) do
      create :evaluation, campagne: ma_campagne, created_at: DateTime.now, nom: 'Jean'
    end

    it 'Je ne vois que les évaluations liées à mes campagnes' do
      visit admin_evaluations_path
      expect(page).to have_content 'Paris 2019'
      expect(page).to_not have_content 'Rouen 2019'

      within('#filters_sidebar_section') do
        expect(page).to have_content 'Paris 2019'
        expect(page).to_not have_content 'Rouen 2019'
      end
    end

    it 'Trie les évaluations de la plus récentes à la plus vieille' do
      visit admin_evaluations_path
      within '.odd:first-of-type' do
        expect(page).to have_content 'Jean'
      end
    end
  end
end
