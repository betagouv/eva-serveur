# frozen_string_literal: true

require 'rails_helper'

describe Structure, type: :model do
  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_uniqueness_of(:nom).scoped_to(:code_postal).case_insensitive }

  it do
    expect(subject).to belong_to(:structure_referente).class_name('StructureAdministrative')
                                                      .optional
  end

  describe 'géolocalisation à la validation' do
    describe "pour n'importe quel code postal" do
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
        expect(structure.latitude).to be(40.7143528)
        expect(structure.longitude).to be(-74.0059731)
        expect(structure.region).to eql('Île-de-France')
      end

      it { expect(Structure.geocoder_options[:params]).to include(countrycodes: 'fr') }
    end

    describe 'si ma structure a un code postal commençant par 988' do
      let(:structure) { Structure.new code_postal: '98850' }

      before do
        Geocoder::Lookup::Test.add_stub(
          '98850', [
            {
              'state' => '',
              'coordinates' => [47.3129, 120.0596]
            }
          ]
        )
        structure.valid?
      end

      it 'lui attribue la région Nouvelle-Calédonie' do
        expect(structure.region).to eql('Nouvelle-Calédonie')
      end
    end
  end
end
