# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Evaluation', type: :feature do
  before(:each) { se_connecter_comme_organisation }

  let(:ma_campagne) do
    create :campagne, compte: Compte.first, libelle: 'Paris 2019', code: 'paris2019'
  end

  describe '#show' do
    # evaluation sans positionnement
    let!(:mon_evaluation) { create :evaluation, campagne: ma_campagne, created_at: 3.days.ago }
    let(:situation) { build(:situation_inventaire) }
    let!(:partie) { create :partie, situation: situation, evaluation: mon_evaluation }
    let!(:evenement) { create :evenement_demarrage, partie: partie }
    let(:restitution) { Restitution::Inventaire.new(ma_campagne, [evenement]) }

    # evaluation avec positionnement
    let!(:mon_evaluation_bienvenue) { create :evaluation, campagne: ma_campagne }
    let(:bienvenue) { build(:situation_bienvenue, questionnaire: questionnaire) }
    let!(:partie_bienvenue) do
      create :partie, situation: bienvenue, evaluation: mon_evaluation_bienvenue
    end
    let!(:evenement_bienvenue) { create :evenement_demarrage, partie: partie_bienvenue }
    let(:questionnaire) { create :questionnaire, questions: [] }
    let(:restitution_bienvenue) do
      Restitution::Bienvenue.new(mon_evaluation_bienvenue, [evenement_bienvenue])
    end

    it 'sans auto_positionnement' do
      visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation)
      expect(page).to_not have_content 'Auto-positionnement'
      expect(page).to have_content 'Roger'
    end

    it 'avec auto_positionnement' do
      visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
      expect(page).to have_content 'Auto-positionnement'
      expect(page).to have_content 'Roger'
    end

    describe 'en moquant restitution_globale :' do
      let(:restitution_globale) do
        double(Restitution::Globale,
               date: DateTime.now,
               utilisateur: 'Roger',
               efficience: 5,
               restitutions: [restitution])
      end

      before do
        competences = [{ Competence::ORGANISATION_METHODE => Competence::NIVEAU_4 }]
        expect(restitution_globale).to receive(:niveaux_competences).and_return(competences)
        expect(FabriqueRestitution).to receive(:restitution_globale).and_return(restitution_globale)
      end

      it 'affiche le niveau litteratie et numératie' do
        expect(restitution_globale).to receive(:interpretations_niveau1)
          .and_return([{ litteratie: :a1 }, { numeratie: :x1 }])
        visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
        expect(page).to have_content 'Niveau A1'
        expect(page).to have_content 'Niveau X1'
      end

      it "affiche que le score n'a pas pu être calculé" do
        expect(restitution_globale).to receive(:interpretations_niveau1)
          .and_return([{ litteratie: nil }])
        visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
        expect(page).to have_content "Votre score n'a pas pu être calculé"
      end

      it "Socle cléa en cours d'acquisition" do
        expect(restitution_globale).to receive(:interpretations_niveau1)
          .and_return([{ socle_clea: :atteint }])
        visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation_bienvenue)
        expect(page).to have_content 'Socle Cléa'
      end

      it "affiche l'évaluation en pdf" do
        allow(restitution_globale).to receive(:interpretations_niveau1).and_return([])
        allow(restitution_globale).to receive(:structure).and_return('Mission locale Paris')
        visit admin_campagne_evaluation_path(ma_campagne, mon_evaluation, format: :pdf)
        path = page.save_page

        reader = PDF::Reader.new(path)
        expect(reader.page(1).text).to include('Roger')
        expect(reader.page(1).text).to include('Mission locale Paris')
      end
    end
  end

  describe 'suppression' do
    let(:evaluation) { create :evaluation, campagne: ma_campagne }
    let(:situation) { create :situation_tri }
    let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
    let!(:evenement) { create :evenement, partie: partie }
    before { visit admin_campagne_evaluation_path(ma_campagne, evaluation) }

    it do
      expect { click_on 'Supprimer' }.to(change { Evaluation.count }
                                     .and(change { Evenement.count }))
      expect(page.current_url).to eql(admin_campagne_url(ma_campagne))
    end
  end
end
