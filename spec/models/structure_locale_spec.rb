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

  describe "#code_postal_manquant?" do
    context "quand code_postal est blank" do
      let(:structure) { described_class.new(code_postal: nil) }

      it { expect(structure).to be_code_postal_manquant }
    end

    context "quand code_postal est TYPE_NON_COMMUNIQUE" do
      let(:structure) { described_class.new(code_postal: described_class::TYPE_NON_COMMUNIQUE) }

      it { expect(structure).to be_code_postal_manquant }
    end

    context "quand code_postal est un code à 5 chiffres" do
      let(:structure) { described_class.new(code_postal: "75012") }

      it { expect(structure).not_to be_code_postal_manquant }
    end
  end

  describe '#usage' do
    it do
      expect(subject).to validate_inclusion_of(:usage).in_array([ "Eva: bénéficiaires",
                                                                   "EVAPRO" ])
    end
  end

  describe '#evapro?' do
    context 'quand la structure est une entreprise' do
      let(:structure) do
        described_class.new(type_structure: "entreprise", usage: "EVAPRO")
      end

      it { expect(structure).to be_evapro }
    end

    context 'quand la structure n\'est pas une entreprise' do
      let(:structure) do
        described_class.new(type_structure: "mission_locale", usage: "Eva: bénéficiaires")
      end

      it { expect(structure).not_to be_evapro }
    end

    context 'quand le type est entreprise mais l\'usage est bénéficiaires' do
      let(:structure) do
        described_class.new(type_structure: "entreprise", usage: "Eva: bénéficiaires")
      end

      it { expect(structure).not_to be_evapro }
    end

    context "quand le type n'est pas entreprise mais l'usage est entreprises" do
      let(:structure) do
        described_class.new(type_structure: "mission_locale", usage: "EVAPRO")
      end

      it { expect(structure).to be_evapro }
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

        it "affecte l'usage 'EVAPRO'" do
          structure.affecte_usage_entreprise_si_necessaire
          expect(structure.usage).to eq("EVAPRO")
        end
      end

      context 'quand le type_structure est entreprise et usage est déjà "EVAPRO"' do
        let(:structure) do
          described_class.new(nom: "Test", code_postal: "75012", siret: "12345678901234",
                              type_structure: "entreprise", usage: "EVAPRO")
        end

        it "ne modifie pas l'usage existant" do
          structure.affecte_usage_entreprise_si_necessaire
          expect(structure.usage).to eq("EVAPRO")
        end
      end

      context 'quand le type_structure est entreprise et usage est "Eva: bénéficiaires"' do
        let(:structure) do
          described_class.new(nom: "Test", code_postal: "75012", siret: "12345678901234",
                              type_structure: "entreprise", usage: "Eva: bénéficiaires")
        end

        it "force l'usage à 'EVAPRO'" do
          structure.affecte_usage_entreprise_si_necessaire
          expect(structure.usage).to eq("EVAPRO")
        end
      end

      context 'quand la valeur historique "Eva: entreprises" est encore présente' do
        let(:structure) do
          described_class.new(nom: "Test", code_postal: "75012", siret: "12345678901234",
                              type_structure: "entreprise", usage: "Eva: entreprises")
        end

        it "normalise l'usage vers EVAPRO" do
          structure.affecte_usage_entreprise_si_necessaire
          expect(structure.usage).to eq("EVAPRO")
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

  describe '#pour_inscription' do
    let(:structure1) { create(:structure_locale, siret: siret_1, nom: "B", code_postal: "75000") }
    let(:structure2) do
      structure = build(:structure_locale, siret: siret_2, nom: "A", code_postal: "45000")
      structure.save(validate: false)
      structure
    end

    context 'quand les structures ont le même SIRET' do
      let(:siret_1) { '12345678901234' }
      let(:siret_2) { '12345678901234' }

      it "retourne toutes les structures, triées par nom" do
        expect(described_class.pour_inscription(structure1.siret))
          .to eq([ structure2, structure1 ])
      end

      context "et le même nom" do
        before do
          structure1.update(nom: "Même nom")
          structure2.update(nom: "Même nom")
        end

        it "trie par id" do
          attendu = [ structure1.reload, structure2.reload ].sort_by(&:id)
          expect(described_class.pour_inscription(siret_1)).to eq(attendu)
        end
      end
    end

    context 'quand les structures ont des SIRET différents' do
      let(:siret_1) { '12345678901234' }
      let(:siret_2) { '12345678901235' }

      it "retourne seulement la bonne structure" do
        expect(described_class.pour_inscription(structure1.siret)).to include(structure1)
      end
    end
  end
end
