# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne', type: :feature do
  let(:compte_organisation) { create :compte_organisation }
  let!(:compte_connecte) { connecte(compte_organisation) }
  let!(:ma_campagne) do
    create :campagne, libelle: 'Amiens 18 juin', code: 'A5RC8', compte: compte_connecte
  end
  let!(:campagne) do
    autre_compte_organisation = create :compte_organisation, email: 'orga@eva.fr'
    create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN', compte: autre_compte_organisation
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
          expect(page).to have_content 'Éval.'
        end
        within('td.col-nombre_evaluations') do
          expect(page).to have_content '1'
        end
      end
    end
  end

  describe 'création' do
    let!(:questionnaire) { create :questionnaire, libelle: 'Mon QCM' }

    context 'en administrateur' do
      before do
        compte_organisation.update(role: 'administrateur')
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
        select 'Mon QCM'
      end

      context 'crée la campagne, associé au compte courant et initialise les situations' do
        let!(:situation) { create :situation_inventaire }
        before { fill_in :campagne_code, with: 'EUROCKS' }
        it do
          expect { click_on 'Créer' }.to(change { Campagne.count })
          campagne = Campagne.order(:created_at).last
          expect(campagne.code).to eq 'EUROCKS'
          expect(campagne.compte).to eq compte_organisation
          expect(page).to have_content situation.libelle
          expect(page).to have_content 'Mon QCM'
        end
      end
    end

    context 'en organisation' do
      before do
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
        fill_in :campagne_code, with: 'BELFORT2021'
      end

      it do
        expect { click_on 'Créer' }.to(change { Campagne.count })
        campagne = Campagne.order(:created_at).last
        expect(campagne.libelle).to eq 'Belfort, pack demandeur'
        expect(campagne.code).to eq 'BELFORT2021'
        expect(campagne.compte).to eq compte_organisation
      end
    end
  end

  describe 'show' do
    context 'en admin' do
      let(:situation) { create :situation_inventaire }
      before do
        compte_organisation.update(role: 'administrateur')
        campagne.situations_configurations.create! situation: situation
        visit admin_campagne_path campagne
      end
      it { expect(page).to have_content 'Inventaire' }
    end

    context 'en organisation' do
      before { visit admin_campagne_path(ma_campagne) }
      it do
        expect(page).to_not have_content 'les stats'
        expect(page).to_not have_content 'les événements'
      end
    end
  end
end
