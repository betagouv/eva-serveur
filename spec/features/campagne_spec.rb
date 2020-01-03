# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne', type: :feature do
  let!(:compte_connecte) { se_connecter_comme_organisation }
  let!(:ma_campagne) do
    create :campagne, libelle: 'Amiens 18 juin', code: 'A5RC8', compte: Compte.first
  end
  let(:compte_organisation) { create :compte_organisation, email: 'orga@eva.fr' }
  let!(:campagne) do
    create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN', compte: compte_organisation
  end
  let!(:evaluation) { create :evaluation, campagne: campagne }
  let!(:evaluation_organisation) { create :evaluation, campagne: ma_campagne }

  describe 'index' do
    context 'en organisation' do
      before { visit admin_campagnes_path }

      it do
        expect(page).to have_content 'Amiens 18 juin'
        expect(page).to have_content 'A5RC8'
        expect(page).to_not have_content 'Rouen 30 mars'
      end

      it 'ne permet pas de filtrer par compte' do
        within '.panel_contents' do
          expect(page).to_not have_content 'Compte'
        end
      end
    end

    context 'en administrateur' do
      before do
        compte_connecte.update(role: 'administrateur')
        visit admin_campagnes_path
      end

      it 'permet de filtrer par compte' do
        within '.panel_contents' do
          expect(page).to have_content 'Compte'
        end
      end
    end

    context 'quelque soit le rôle' do
      before { visit admin_campagnes_path }

      it "affiche le nombre d'évaluation par campagne" do
        within('#index_table_campagnes') do
          expect(page).to have_content "Nombre d'évaluations"
        end
        within('td.col-nombre_evaluations') do
          expect(page).to have_content '1'
        end
      end
    end
  end

  describe 'création' do
    let!(:questionnaire) { create :questionnaire, libelle: 'Mon QCM' }

    context 'en organisation' do
      before do
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
      end

      context 'génère un code si on en saisit pas' do
        before do
          fill_in :campagne_code, with: ''
          select 'Mon QCM'
        end

        it do
          expect { click_on 'Créer' }.to(change { Campagne.count })
          expect(Campagne.last.code).to be_present
          expect(Campagne.last.compte).to eq compte_connecte
          expect(page).to have_content 'Mon QCM'
        end

        context 'conserve le code saisi si précisé' do
          before { fill_in :campagne_code, with: 'EUROCKS' }
          it do
            expect { click_on 'Créer' }.to(change { Campagne.count })
            expect(Campagne.last.code).to eq 'EUROCKS'
          end
        end
      end
    end

    context 'en administrateur' do
      before do
        Compte.first.update(role: 'administrateur')
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
        fill_in :campagne_code, with: ''
        select 'Mon QCM'
        select 'orga@eva.fr'
      end

      it do
        expect { click_on 'Créer' }.to(change { Campagne.count })
        expect(Campagne.last.compte).to eq compte_organisation
      end
    end
  end

  describe 'show' do
    let(:situation) { create :situation_inventaire }
    let(:evaluation) { create :evaluation, campagne: campagne }

    let!(:partie) do
      create :partie,
             situation: situation,
             evaluation: evaluation,
             evenements: [evenement]
    end

    let(:evenement) { build :evenement, nom: 'ouvertureContenant' }

    before do
      Compte.first.update(role: 'administrateur')
      campagne.situations_configurations.create! situation: situation
      visit admin_campagne_path campagne
    end

    it { expect(page).to have_content 'Inventaire' }

    context 'télécharger les événements de la campagne' do
      let(:autre_evaluation) { create :evaluation }
      let!(:autre_partie) do
        create :partie, session_id: 'autre', situation: situation, evaluation: autre_evaluation
      end
      let!(:evenement_hors_campagne) { create :evenement, nom: 'horsCampagne', session_id: 'autre' }
      before { click_on 'Télécharger les événements' }

      it do
        expect(page.response_headers['Content-Type']).to eq 'text/csv; charset=utf-8'
        expect(page).to have_content  "Nom de l'évalué·e"
        expect(page).to have_content  'ouvertureContenant'
        expect(page).to_not have_content 'horsCampagne'
      end
    end
  end
end
