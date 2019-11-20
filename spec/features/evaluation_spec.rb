# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evaluation', type: :feature do
  before(:each) { se_connecter_comme_organisation }

  let(:ma_campagne) do
    create :campagne, compte: Compte.first, libelle: 'Paris 2019', code: 'paris2019'
  end

  context "en tant qu'organisation" do
    let(:compte_rouen) { create :compte, role: 'organisation' }
    let(:campagne_rouen) { create :campagne, compte: compte_rouen, libelle: 'Rouen 2019' }
    let!(:evaluation) { create :evaluation, campagne: campagne_rouen }

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

  describe '#show' do
    let!(:mon_evaluation) { create :evaluation, campagne: ma_campagne, created_at: 3.days.ago }
    let(:situation) { build(:situation_inventaire) }
    let(:evenement) { build(:evenement_demarrage, situation: situation) }
    let(:restitution) { Restitution::Inventaire.new(ma_campagne, [evenement]) }
    let(:restitution_globale) do
      double(Restitution::Globale,
             date: DateTime.now,
             utilisateur: 'Roger',
             efficience: 5,
             restitutions: [restitution])
    end

    it "affiche l'évaluation" do
      visit admin_evaluation_path(mon_evaluation)
      expect(page).to have_content 'Roger'
    end

    it "affiche l'évaluation en pdf" do
      competences = [{ Competence::ORGANISATION_METHODE => Competence::NIVEAU_4 }]
      expect(restitution_globale).to receive(:niveaux_competences).and_return(competences)
      expect(FabriqueRestitution).to receive(:restitution_globale).and_return(restitution_globale)
      visit admin_evaluation_path(mon_evaluation, format: :pdf)
      path = page.save_page

      reader = PDF::Reader.new(path)
      expect(reader.page(1).text).to include('Roger')
    end
  end

  describe 'suppression' do
    let(:evaluation) { create :evaluation, campagne: ma_campagne }
    let(:situation) { create :situation_tri }
    let!(:evenement) { create :evenement, evaluation: evaluation, situation: situation }
    before { visit admin_evaluation_path(evaluation) }

    it do
      expect { click_on 'Supprimer' }.to(change { Evaluation.count }
                                     .and(change { Evenement.count }))
    end
  end
end
