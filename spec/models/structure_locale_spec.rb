require 'rails_helper'

describe StructureLocale, type: :model do
  it { is_expected.to validate_presence_of(:code_postal) }
  it { is_expected.to validate_presence_of(:type_structure) }
  it { is_expected.to validate_numericality_of(:code_postal) }
  it { is_expected.to validate_length_of(:code_postal).is_equal_to(5) }

  it do
    types_structures = %w[
      mission_locale france_travail SIAE service_insertion_collectivite CRIA
      organisme_formation orientation_scolaire cap_emploi e2c SMA autre
    ]
    expect(subject).to validate_inclusion_of(:type_structure).in_array(types_structures)
  end

  it "Le code postal ne peut pas comporter d'espaces" do
    structure = described_class.create(nom: 'eva', code_postal: '7501 2 ')
    expect(structure.code_postal).to eq('75012')
  end

  it 'Accepte les codes postaux commençant par 0' do
    structure = described_class.create(nom: 'eva', code_postal: '01000')
    expect(structure.code_postal).to eq('01000')
  end

  describe '#display_name' do
    it do
      expect(described_class.new(nom: 'eva', code_postal: '75012')
                            .display_name).to eql('eva - 75012')
    end
  end
end
