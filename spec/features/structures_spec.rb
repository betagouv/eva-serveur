# frozen_string_literal: true

require 'rails_helper'

describe 'Structures', type: :feature do
  before do
    Geocoder::Lookup::Test.add_stub(
      '75012', [
        {
          'coordinates' => [40.7143528, -74.0059731]
        }
      ]
    )
    Geocoder::Lookup::Test.add_stub(
      '75013', [
        {
          'coordinates' => [40.7143529, -74.0059730]
        }
      ]
    )
    Geocoder::Lookup::Test.add_stub(
      '69000', [
        {
          'coordinates' => [50.7143528, 74.0059731]
        }
      ]
    )
  end

  describe "#index liste les structures proche d'un code postal" do
    let!(:structure_paris12) { create :structure, nom: 'MILO Paris 12eme', code_postal: '75012' }
    let!(:structure_paris13) { create :structure, nom: 'MILO Paris 13eme', code_postal: '75013' }
    let!(:structure_lyon) { create :structure, nom: 'MILO Lyon', code_postal: '69000' }

    it do
      visit structures_path
      expect(page).to_not have_content 'MILO Paris 12eme'
      fill_in :code_postal, with: '75012'
      click_on 'chercher'
      expect(page).to have_content 'MILO Paris 12eme'
      expect(page).to have_content 'MILO Paris 13eme'
      expect(page).to_not have_content 'MILO Lyon'
    end
  end
end
