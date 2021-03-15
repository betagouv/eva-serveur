# frozen_string_literal: true

require 'rails_helper'

describe Structure, type: :model do
  context 'avec un geocoder de test' do
    before do
      Geocoder.configure(lookup: :test)
    end

    it { should validate_presence_of(:nom) }
    it { should validate_presence_of(:code_postal) }

    it 'geocode à la création' do
      Geocoder::Lookup::Test.add_stub(
        '75012', [
          {
            'coordinates' => [40.7143528, -74.0059731]
          }
        ]
      )
      structure = create :structure, code_postal: '75012'
      expect(structure.latitude).to eql(40.7143528)
      expect(structure.longitude).to eql(-74.0059731)
    end
  end
end
