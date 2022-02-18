# frozen_string_literal: true

require 'rails_helper'

describe Structure, type: :model do
  it { is_expected.to validate_presence_of(:nom) }
  it do
    is_expected.to belong_to(:structure_referente).class_name('StructureAdministrative').optional
  end

  describe 'géolocalisation à la validation' do
    let(:structure) { Structure.new code_postal: '75012' }
    before do
      Geocoder::Lookup::Test.add_stub(
        '75012', [
          {
            'coordinates' => [40.7143528, -74.0059731],
            'state' => 'Île-de-France'
          }
        ]
      )
      structure.valid?
    end

    it do
      expect(structure.latitude).to eql(40.7143528)
      expect(structure.longitude).to eql(-74.0059731)
      expect(structure.region).to eql('Île-de-France')
    end

    it { expect(Structure.geocoder_options[:params]).to include(countrycodes: 'fr') }
  end
end
