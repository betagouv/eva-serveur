require 'rails_helper'

describe StructureLocale, type: :model do
  describe 'validations' do
    it do
     expect(subject).to validate_presence_of(:code_postal)
     expect(subject).to validate_presence_of(:type_structure)
     expect(subject).to validate_numericality_of(:code_postal)
     expect(subject).to validate_length_of(:code_postal).is_equal_to(5)
        end
  end

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

  describe '#usage' do
    it {
 expect(subject).to validate_inclusion_of(:usage).in_array([ "Eva: bénéficiaires",
"Eva: entreprises" ]) }
  end

  describe '#eva_entreprises?' do
    context 'quand la structure est une entreprise' do
      structure = described_class.new(type_structure: "entreprise", usage: "Eva: entreprises")

      it { expect(structure).to be_eva_entreprises }
    end

    context 'quand la structure n\'est pas une entreprise' do
      structure = described_class.new(type_structure: "mission_locale", usage: "Eva: bénéficiaires")
      it { expect(structure).not_to be_eva_entreprises }
    end
  end
end
