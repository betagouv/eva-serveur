# frozen_string_literal: true

require 'rails_helper'

describe 'Admin - Actualite', type: :feature do
  describe 'index' do
    let(:structure) { create :structure }
    let!(:compte_admin) { create :compte_admin, structure: structure }
    let(:compte_conseiller) { create(:compte_conseiller, structure: structure) }
    let!(:compte_connecte) { connecte(compte_conseiller) }
    let!(:actualite) { create :actualite }

    before { visit admin_actualites_path }

    context 'quelque soit le rôle' do
      it 'peut voir une actualité' do
        within('.action') do
          expect(page).to have_content 'Lire'
          expect(page).to_not have_content 'Modifier'
          expect(page).to_not have_content 'Supprimer'
        end
      end
    end

    context "en tant qu'admin" do
      before do
        compte_connecte.update!(role: 'admin')
        refresh
      end

      it 'peut supprimer ou modifier une actualité' do
        within '.action' do
          expect(page).to have_content 'Modifier'
          expect(page).to have_content 'Supprimer'
        end
      end
    end
  end
end
