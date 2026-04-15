require 'rails_helper'

describe 'Structures', type: :feature do
  describe '#show' do
    before { connecte(compte) }

    describe 'menu latéral de gestion' do
      let!(:compte_admin) { create :compte_admin }

      context 'quand je suis connecté avec un compte admin' do
        let!(:compte) { compte_admin }

        it 'affiche le block Gestion car il y a une action de modification possible' do
          visit admin_structure_locale_path(compte.structure_id)

          within '#action_items_sidebar_section' do
            expect(page).to have_content 'Gestion'
          end
        end
      end

      context 'quand je suis connecté avec un compte conseiller' do
        let!(:compte) { create :compte_conseiller, structure: compte_admin.structure }

        it "n'affiche pas le block Gestion car il n'y a pas d'action possible" do
          visit admin_structure_locale_path(compte.structure_id)
          expect(page).not_to have_css('#action_items_sidebar_section')
        end
      end
    end

    describe 'section campagne' do
      let!(:compte) { create :compte_admin }

      context "lorsqu'il n'y a pas de campagnes associées à la structure" do
        it "affiche un message qui explique qu'il n'y a pas de campagne pour le moment" do
          visit admin_structure_locale_path(compte.structure_id)
          expect(page).to have_content 'Pas de campagne à afficher pour le moment.'
        end
      end

      context "lorsqu'il y a des campagnes associées à la structure" do
        let!(:campagne) { create :campagne, compte: compte }

        it 'affiche les campagnes' do
          visit admin_structure_locale_path(compte.structure_id)
          expect(page).to have_content campagne.libelle
        end
      end
    end
  end
end
