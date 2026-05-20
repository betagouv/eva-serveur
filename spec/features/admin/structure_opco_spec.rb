require 'rails_helper'

describe 'Admin - Structure Operateur de competence' do
  context 'en tant que superadmin' do
    let(:compte_superadmin) { create(:compte_superadmin) }

    before { connecte(compte_superadmin) }

    describe "index" do
      let!(:structure) { create :structure_opco, nom: 'Structure AFDAS' }

      it "affiche les structures OPCO" do
        visit admin_structures_opcos_path

        expect(page).to have_content 'Structure AFDAS'
      end
    end

    describe "show" do
      let(:structure) { create :structure_opco, :avec_admin, nom: 'Structure AFDAS' }

      before { visit admin_structure_opco_path(structure) }

      describe 'Ma structure' do
        it { expect(page).to have_content structure.nom }

        it do
          message = 'Ici vous pouvez gérer votre structure et vos collègues ayant accès à eva.'
          expect(page).to have_content message
        end
      end

      context "affiche le bloc des statistiques OPCO" do
        it "affiche la section Statistiques avec le dashboard metabase opco" do
          visit admin_structure_opco_path(structure)

          expect(page).to have_css("#bloc-statistiques")
          expect(page).not_to have_content(I18n.t("admin.structures.statistiques.description.correlation_donnees_illettrisme"))
        end
      end

      context "bloc membres - invitation" do
        it "affiche le bouton envoyer une invitation" do
          visit admin_structure_opco_path(structure)

          expect(page).to have_content("Envoyer une invitation")
        end
      end
    end

    describe 'création' do
      let!(:opco) { create(:opco, nom: "OPCO Test") }
      let!(:structure) {
        create :structure_opco, :avec_admin, nom: 'Ma structure',
        siret: '12345678901234', opco: opco
      }

      it "permet de créer une structure avec le même SIRET" do
        visit new_admin_structure_opco_path

        fill_in :structure_opco_nom, with: "Nouvelle structure"
        fill_in :structure_opco_siret, with: "12345678901234"
        select "OPCO Test", from: "structure_opco_opco_id"
        click_on "Créer une structure"

        structure = Structure.order(:created_at).last
        expect(structure.nom).to eq "Nouvelle structure"
        expect(structure.usage).to eq AvecUsage::USAGE_BENEFICIAIRES
        expect(structure.opco).to eq(opco)
      end
    end

    describe 'modification' do
      let!(:structure_a_modifier) { create(:structure_administrative, siret: '98765432109876') }

      it 'permet de modifier le SIRET pour un SIRET déjà utilisé' do
        visit edit_admin_structure_administrative_path(structure_a_modifier)

        fill_in :structure_administrative_siret, with: '12345678901234'
        click_on 'Modifier'

        structure_a_modifier.reload
        expect(structure_a_modifier.siret).to eq '12345678901234'
      end
    end
  end

  context 'en tant que admin' do
    let!(:structure) { create(:structure_opco, siret: '12345678901234') }
    let!(:compte_admin) { create(:compte_admin, structure: structure) }

    before { connecte(compte_admin) }

    describe 'create' do
      it 'ne permet pas de créer une structure' do
        visit new_admin_structure_opco_path

        expect(page).to have_content "Vous n'êtes pas autorisé à exécuter cette action"
      end
    end

    describe 'update' do
      it 'ne permet pas de modifier une structure avec un même SIRET deja affecté' do
        create :structure_opco, siret: '12345678901212'
        visit edit_admin_structure_opco_path(structure)
        fill_in :structure_opco_siret, with: '12345678901212'
        click_on 'Modifier'

        expect(page).to have_content "Ce SIRET est déjà utilisé"
        expect(structure.reload.siret).to eq '12345678901234'
      end
    end
  end

  context 'en tant qu\'admin de structure administrative' do
    let(:structure_administrative) { create(:structure_administrative) }
    let!(:compte_admin) { create(:compte_admin, structure: structure_administrative) }

    before { connecte(compte_admin) }

    describe 'index' do
      it 'ne peut pas accéder à la liste des structures opco' do
        visit admin_structures_opcos_path
        expect(page).to have_content "Vous n'êtes pas autorisé à exécuter cette action"
      end
    end

    describe 'show' do
      let!(:structure_opco) { create(:structure_opco) }

      it 'ne peut pas accéder au detail d\'une structure opco' do
        visit admin_structure_opco_path(structure_opco)
        expect(page).to have_content "Vous n'êtes pas autorisé à exécuter cette action"
      end
    end
  end
end
