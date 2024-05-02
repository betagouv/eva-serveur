# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Campagne', type: :feature do
  let(:structure_conseiller) { create :structure_locale }
  let(:compte_conseiller) { create :compte_admin, structure: structure_conseiller }
  let!(:compte_connecte) { connecte(compte_conseiller) }

  describe 'index' do
    let!(:ma_campagne) do
      create :campagne, libelle: 'Amiens 18 juin', code: 'A5RC8', compte: compte_connecte
    end
    let!(:campagne) do
      autre_compte_conseiller = create :compte_admin, email: 'orga@eva.fr'
      create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN', compte: autre_compte_conseiller
    end

    context 'en conseiller' do
      before { visit admin_campagnes_path }

      it do
        expect(page).to have_content 'Amiens 18 juin'
        expect(page).to have_content 'A5RC8'
        expect(page).not_to have_content 'Rouen 30 mars'
      end

      it 'permet de filtrer par compte' do
        within '#filters_sidebar_section' do
          expect(page).to have_content 'Compte'
        end
      end
    end

    context 'en superadmin' do
      before do
        compte_connecte.update(role: 'superadmin')
        visit admin_campagnes_path
      end

      it 'permet de filtrer par compte' do
        within '#filters_sidebar_section' do
          expect(page).to have_content 'Compte'
        end
      end
    end

    context 'quelque soit le rôle' do
      let!(:evaluation) { create :evaluation, campagne: campagne }
      let!(:evaluation_conseiller) { create :evaluation, campagne: ma_campagne }
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
        fill_in :campagne_code, with: 'CODESUPERADMIN'
      end

      context 'crée la campagne, associé au compte courant' do
        before do
          choose "campagne_type_programme_#{parcours_type_complet.type_de_programme}"
          choose "campagne_parcours_type_id_#{parcours_type_complet.id}"
          click_on 'Créer'
        end

        it do
          campagne = Campagne.order(:created_at).last
          expect(campagne.code).to eq 'CODESUPERADMIN'
          expect(campagne.compte).to eq compte_conseiller

          situations_configurations = campagne.situations_configurations.includes(:situation)
          expect(situations_configurations[0].situation).to eq situation_inventaire
          expect(situations_configurations[1].situation).to eq situation_maintenance
        end
      end
    end

    context 'en conseiller' do
      let!(:parcours_type_competences_de_base) do
        parcours = create :parcours_type, nom_technique: :competences_de_base
        parcours.situations_configurations.create situation: situation_maintenance
        parcours
      end
      let!(:situation_plan_de_la_ville) { create :situation_plan_de_la_ville }
      let(:structure_conseiller) { create :structure_locale, code_postal: '45312' }

      before do
        allow(GenerateurAleatoire).to receive(:majuscules).with(3).and_return 'CDI'
        visit new_admin_campagne_path
        fill_in :campagne_libelle, with: 'Belfort, pack demandeur'
      end

      context 'choisir son parcours' do
        before do
          Bullet.enable = false
          choose "campagne_type_programme_#{parcours_type_complet.type_de_programme}"
          choose "campagne_parcours_type_id_#{parcours_type_complet.id}"
          click_on 'Créer'
          Bullet.enable = true
        end

        it do
          campagne = Campagne.order(:created_at).last
          expect(campagne.libelle).to eq 'Belfort, pack demandeur'
          expect(campagne.code).to eq 'CDI45312'
          expect(campagne.compte).to eq compte_conseiller
          within('.panel-programme') do
            expect(page).to have_content parcours_type_complet.libelle
          end
        end
      end

      it 'sélectionne des modules de parcours optionnels' do
        Bullet.enable = false
        choose "campagne_type_programme_#{parcours_type_complet.type_de_programme}"
        choose "campagne_parcours_type_id_#{parcours_type_complet.id}"
        check 'campagne_options_personnalisation_plan_de_la_ville'
        click_on 'Créer'
        Bullet.enable = true

        campagne = Campagne.order(:created_at).last
        expect(Campagne.avec_situation(situation_plan_de_la_ville).first).to eq campagne
      end
    end
  end

  describe 'modification' do
    let!(:questionnaire_sans_livraison) { create :questionnaire, :livraison_sans_redaction }
    let!(:questionnaire_avec_livraison) { create :questionnaire, :livraison_avec_redaction }
    let!(:situation_livraison) do
      create :situation_livraison, questionnaire: questionnaire_sans_livraison
    end
    let!(:parcours_type) do
      parcours = create :parcours_type, nom_technique: :parcours_type
      parcours.situations_configurations.create situation: situation_livraison
      parcours
    end
    let!(:campagne) do
      autre_compte_conseiller = create :compte_admin, email: 'orga@eva.fr'
      create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN',
                        compte: autre_compte_conseiller, parcours_type: parcours_type
    end

    context 'en superadmin' do
      before do
        compte_conseiller.update(role: 'superadmin')
        visit edit_admin_campagne_path(campagne)
      end

      context 'modifie la campagne et ses situations' do
        before do
          fill_in :campagne_code, with: 'UNC0D3'
          select 'Livraison avec rédaction',
                 from: 'campagne_situations_configurations_attributes_0_questionnaire_id'
          expect do
            click_on 'Modifier la campagne'
          end.to raise_error(Bullet::Notification::UnoptimizedQueryError,
                             /AVOID eager loading detected/)
        end

        it do
          campagne = Campagne.order(:created_at).last
          expect(campagne.code).to eq 'UNC0D3'

          situations_configurations = campagne.situations_configurations.includes(:situation)
          expect(situations_configurations[0].situation).to eq situation_livraison
          expect(situations_configurations[0].questionnaire).to eq questionnaire_avec_livraison
        end
      end
    end
  end

  describe 'suppression' do
    let!(:campagne) do
      autre_compte_conseiller = create :compte_admin, email: 'orga@eva.fr'
      create :campagne, libelle: 'Rouen 30 mars', code: 'A5ROUEN', compte: autre_compte_conseiller
    end
    let!(:evaluation) { create :evaluation, campagne: campagne }

    context 'quand je supprime une campagne avec des évaluations associées déjà supprimée' do
      before do
        evaluation.destroy
        campagne.destroy
      end

      it "soft_delete la campagne mais garde l'association avec l'evaluation" do
        expect(campagne.deleted_at).not_to be nil
        expect(evaluation.campagne_id).to eq campagne.id
      end
    end
  end
end
