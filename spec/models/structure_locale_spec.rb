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
    it do
      expect(subject).to validate_inclusion_of(:usage).in_array([ "Eva: bénéficiaires",
                                                                   "Eva: entreprises" ])
    end
  end

  describe '#eva_entreprises?' do
    context 'quand la structure est une entreprise' do
      let(:structure) do
        described_class.new(type_structure: "entreprise", usage: "Eva: entreprises")
      end

      it { expect(structure).to be_eva_entreprises }
    end

    context 'quand la structure n\'est pas une entreprise' do
      let(:structure) do
        described_class.new(type_structure: "mission_locale", usage: "Eva: bénéficiaires")
      end

      it { expect(structure).not_to be_eva_entreprises }
    end

    context 'quand le type est entreprise mais l\'usage est bénéficiaires' do
      let(:structure) do
        described_class.new(type_structure: "entreprise", usage: "Eva: bénéficiaires")
      end

      it { expect(structure).not_to be_eva_entreprises }
    end

    context "quand le type n'est pas entreprise mais l'usage est entreprises" do
      let(:structure) do
        described_class.new(type_structure: "mission_locale", usage: "Eva: entreprises")
      end

      it { expect(structure).to be_eva_entreprises }
    end
  end

  describe "#affecte_usage_entreprise_si_necessaire" do
    context "quand ACTIVE_EVAPRO n'est pas définie" do
      let!(:valeur_precedente_active_evapro) { ENV["ACTIVE_EVAPRO"] }
      let(:structure) do
        described_class.new(nom: "Test", code_postal: "75012", siret: "12345678901234",
                            type_structure: "entreprise", usage: nil)
      end

      before { ENV.delete("ACTIVE_EVAPRO") }

      after { ENV["ACTIVE_EVAPRO"] = valeur_precedente_active_evapro }

      it "ne modifie pas l'usage" do
        structure.affecte_usage_entreprise_si_necessaire
        expect(structure.usage).to be_nil
      end
    end

    context 'quand le type_structure est entreprise et usage est vide' do
        let(:structure) do
          described_class.new(nom: "Test", code_postal: "75012", siret: "12345678901234",
                              type_structure: "entreprise", usage: nil)
        end

        it "affecte l'usage 'Eva: entreprises'" do
          structure.affecte_usage_entreprise_si_necessaire
          expect(structure.usage).to eq("Eva: entreprises")
        end
      end

      context 'quand le type_structure est entreprise et usage est déjà "Eva: entreprises"' do
        let(:structure) do
          described_class.new(nom: "Test", code_postal: "75012", siret: "12345678901234",
                              type_structure: "entreprise", usage: "Eva: entreprises")
        end

        it "ne modifie pas l'usage existant" do
          structure.affecte_usage_entreprise_si_necessaire
          expect(structure.usage).to eq("Eva: entreprises")
        end
      end

      context 'quand le type_structure est entreprise et usage est "Eva: bénéficiaires"' do
        let(:structure) do
          described_class.new(nom: "Test", code_postal: "75012", siret: "12345678901234",
                              type_structure: "entreprise", usage: "Eva: bénéficiaires")
        end

        it "force l'usage à 'Eva: entreprises'" do
          structure.affecte_usage_entreprise_si_necessaire
          expect(structure.usage).to eq("Eva: entreprises")
        end
      end

      context 'quand le type_structure n\'est pas entreprise' do
        let(:structure) do
          described_class.new(nom: "Test", code_postal: "75012", siret: "12345678901234",
                              type_structure: "mission_locale", usage: nil)
        end

        it "ne modifie pas l'usage" do
          structure.affecte_usage_entreprise_si_necessaire
          expect(structure.usage).to be_nil
        end
    end
  end
end
