# frozen_string_literal: true

require 'rails_helper'

describe 'Structures', type: :feature do
  before do
    paris12 = { 'coordinates' => [40.7143528, -74.0059731] }
    Geocoder::Lookup::Test.add_stub('75012, FRANCE', [paris12])
    Geocoder::Lookup::Test.add_stub('75012', [paris12])

    paris13 = { 'coordinates' => [40.7143529, -74.0059730] }
    Geocoder::Lookup::Test.add_stub('75013, FRANCE', [paris13])
    Geocoder::Lookup::Test.add_stub('75013', [paris13])

    lyon = { 'coordinates' => [45.7632404, 4.8338496] }
    Geocoder::Lookup::Test.add_stub('69000, FRANCE', [lyon])
    Geocoder::Lookup::Test.add_stub('69000', [lyon])
  end

  describe "#index liste les structures proche d'un code postal" do
    before do
      create :structure_locale, nom: 'MILO Paris 12eme', code_postal: '75012'
      create :structure_locale, nom: 'MILO Paris 13eme', code_postal: '75013'
      create :structure_locale, nom: 'MILO Lyon', code_postal: '69000'
    end

    it do
      visit structures_path(ville_ou_code_postal: 'Paris (75012)', code_postal: '75012')
      expect(page).to have_content 'MILO Paris 12eme'
      expect(page).to have_content 'MILO Paris 13eme'
      expect(page).not_to have_content 'MILO Lyon'
    end
  end

  describe '#show' do
    before { connecte(compte) }

    describe 'menu latéral de gestion' do
      let!(:compte_admin) { create :compte_admin }

      context 'quand je suis connecté avec un compte admin' do
        let!(:compte) { compte_admin }

        it 'affiche le block Gestion car il y a une action de modification possible' do
          visit admin_structure_locale_path(compte.structure_id)
          expect(page).to have_content 'Gestion'
        end
      end

      context 'quand je suis connecté avec un compte conseiller' do
        let!(:compte) { create :compte_conseiller, structure: compte_admin.structure }

        it "n'affiche pas le block Gestion car il n'y a pas d'action possible" do
          visit admin_structure_locale_path(compte.structure_id)
          expect(page).not_to have_content 'Gestion'
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
