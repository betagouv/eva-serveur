# frozen_string_literal: true

require 'rails_helper'

describe Structure, type: :model do
  it { is_expected.to validate_presence_of(:nom) }
  it { is_expected.to validate_presence_of(:code_postal) }
  it { is_expected.to validate_presence_of(:type_structure) }
  it { is_expected.to validate_numericality_of(:code_postal) }
  it { is_expected.to validate_length_of(:code_postal).is_equal_to(5) }

  it do
    types_structures = %w[
      mission_locale pole_emploi SIAE service_insertion_collectivite CRIA
      organisme_formation orientation_scolaire cap_emploi e2c SMA autre
    ]
    is_expected.to validate_inclusion_of(:type_structure).in_array(types_structures)
  end

  it do
    expect(described_class.new(nom: 'eva', code_postal: '75012')
                          .display_name).to eql('eva - 75012')
  end

  it "Le code postal ne peut pas comporter d'espaces" do
    structure = described_class.create(nom: 'eva', code_postal: '75 01 2 ')
    expect(structure.code_postal).to eq('75012')
  end

  it 'Accepte les codes postaux commençant par 0' do
    structure = described_class.create(nom: 'eva', code_postal: '01000')
    expect(structure.code_postal).to eq('01000')
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
