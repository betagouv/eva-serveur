# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne', type: :feature do
  let(:compte_conseiller) { create :compte_conseiller }
  let!(:compte_connecte) { connecte(compte_conseiller) }
  let!(:ma_campagne) do
    create :campagne, libelle: 'Amiens 18 juin', code: 'A5RC8', compte: compte_connecte
  end
  let!(:campagne) do
    autre_compte_conseiller = create :compte_conseiller, email: 'orga@eva.fr'
    create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN', compte: autre_compte_conseiller
  end
  let!(:evaluation) { create :evaluation, campagne: campagne }
  let!(:evaluation_conseiller) { create :evaluation, campagne: ma_campagne }

  describe 'index' do
    context 'en conseiller' do
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

    context 'en superadmin' do
      before do
        compte_connecte.update(role: 'superadmin')
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
    let!(:situation_inventaire) { create :situation_inventaire }
    let!(:situation_maintenance) { create :situation_maintenance }
    let!(:parcours_type_complet) do
      parcours = create :parcours_type, :complet
      parcours.situations_configurations.create situation: situation_inventaire
      parcours.situations_configurations.create situation: situation_maintenance
      parcours
    end

    context 'en superadmin' do
      before do
        compte_conseiller.update(role: 'superadmin')
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
      end

      context 'crée la campagne, associé au compte courant et initialise les situations' do
        before do
          fill_in :campagne_code, with: 'eurocks'
          choose "campagne_parcours_type_id_#{parcours_type_complet.id}"
          click_on 'Créer'
        end
        it do
          campagne = Campagne.order(:created_at).last
          expect(campagne.code).to eq 'EUROCKS'
          expect(campagne.compte).to eq compte_conseiller
          within('.campagne-parcours table') do
            expect(page).to have_content situation_maintenance.libelle
          end
        end
      end
    end

    context 'en conseiller' do
      let!(:parcours_type_competences_de_base) do
        parcours = create :parcours_type, nom_technique: :competences_de_base
        parcours.situations_configurations.create situation: situation_maintenance
        parcours
      end
      before do
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
        fill_in :campagne_code, with: 'BELFORT2021'
      end

      context 'créer un parcours complet' do
        before do
          choose "campagne_parcours_type_id_#{parcours_type_complet.id}"
          click_on 'Créer'
        end
        it do
          campagne = Campagne.order(:created_at).last
          expect(campagne.libelle).to eq 'Belfort, pack demandeur'
          expect(campagne.code).to eq 'BELFORT2021'
          expect(campagne.compte).to eq compte_conseiller
          within('.campagne-parcours table') do
            expect(page).to have_content situation_maintenance.libelle
            expect(page).to have_content situation_inventaire.libelle
          end
        end
      end

      context 'créer un parcours compétences de base' do
        before do
          choose "campagne_parcours_type_id_#{parcours_type_competences_de_base.id}"
          click_on 'Créer'
        end

        it do
          within('.campagne-parcours table') do
            expect(page).to have_content situation_maintenance.libelle
            expect(page).not_to have_content situation_inventaire.libelle
          end
        end
      end
    end
  end

  describe 'modification' do
    let!(:questionnaire) { create :questionnaire, libelle: 'Mon QCM' }

    context 'en superadmin' do
      before do
        compte_conseiller.update(role: 'superadmin')
        visit edit_admin_campagne_path(campagne)
        select 'Mon QCM'
      end

      context 'modifie la campagne et ses situations' do
        let!(:situation) { create :situation_inventaire }
        before do
          fill_in :campagne_code, with: 'forcelamajuscule'
          click_on 'Enregistrer'
        end

        it do
          campagne = Campagne.order(:created_at).last
          expect(campagne.code).to eq 'FORCELAMAJUSCULE'
          expect(page).to have_content 'Mon QCM'
        end
      end
    end
  end

  describe 'show' do
    context 'en admin' do
      let(:situation) { create :situation_inventaire }
      before do
        compte_conseiller.update(role: 'superadmin')
        campagne.situations_configurations.create! situation: situation
        visit admin_campagne_path campagne
      end
      it { expect(page).to have_content 'Inventaire' }
    end

    context 'en conseiller' do
      before { visit admin_campagne_path(ma_campagne) }
      it do
        expect(page).to_not have_content 'les stats'
        expect(page).to_not have_content 'les événements'
      end
    end
  end
end
