require 'rails_helper'

describe Beneficiaire do
  it { is_expected.to belong_to(:compte).optional }
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_uniqueness_of(:code_beneficiaire).case_insensitive }
  it { is_expected.to allow_value('ABC1234').for(:code_beneficiaire) }
  it { is_expected.not_to allow_value('ABC.123.').for(:code_beneficiaire) }
  it { is_expected.not_to allow_value('abc1234').for(:code_beneficiaire) }

  describe '#genere_code_beneficiaire_unique' do
    let(:beneficiaire) { described_class.new nom: "Mathéo" }

    context 'quand le code_beneficiaire est absent' do
      let(:generateur) { instance_double(GenerateurCode, genere: 'ABC12345') }

      before do
        allow(GenerateurCode).to receive(:new).with(described_class, :code_beneficiaire)
                                              .and_return(generateur)
        beneficiaire.genere_code_beneficiaire_unique
      end

      it 'utilise le générateur de code sans suffixe' do
        expect(generateur).to have_received(:genere).with(no_args)
        expect(beneficiaire.code_beneficiaire).to eq 'ABC12345'
      end
    end

    context 'quand le code_beneficiaire est déjà présent' do
      before do
        beneficiaire.code_beneficiaire = 'CODE123'
        beneficiaire.genere_code_beneficiaire_unique
      end

      it { expect(beneficiaire.code_beneficiaire).to eq 'CODE123' }
    end
  end

  describe ".ransack" do
    let!(:beneficiaire_avec_accents) { create(:beneficiaire, nom: "José García") }
    let!(:beneficiaire_sans_accents) { create(:beneficiaire, nom: "Pierre Dupont") }

    context "avec des paramètres Hash" do
      it "transforme nom_cont en nom_contains_unaccent" do
        resultats = described_class.ransack(nom_cont: "Jose").result
        expect(resultats).to include(beneficiaire_avec_accents)
      end

      it "recherche sans tenir compte des accents dans les deux sens" do
        # Recherche sans accent trouve avec accent
        resultats = described_class.ransack(nom_cont: "Jose").result
        expect(resultats).to include(beneficiaire_avec_accents)

        # Recherche avec accent trouve sans accent
        resultats = described_class.ransack(nom_cont: "Piérre").result
        expect(resultats).to include(beneficiaire_sans_accents)
      end

      it "ne transforme pas les autres paramètres" do
        code_partiel = beneficiaire_avec_accents.code_beneficiaire[0..2]
        resultats = described_class.ransack(code_beneficiaire_cont: code_partiel).result
        expect(resultats).to include(beneficiaire_avec_accents)
      end
    end

    context "avec des paramètres imbriqués (groupings)" do
      it "transforme récursivement les paramètres imbriqués" do
        params = {
          groupings: [
            {
              m: "or",
              nom_cont: "Jose",
              code_beneficiaire_cont: "test"
            }
          ],
          combinator: "and"
        }
        resultats = described_class.ransack(params).result
        expect(resultats).to include(beneficiaire_avec_accents)
      end
    end

    context "avec ActionController::Parameters" do
      it "convertit et transforme les paramètres" do
        params = ActionController::Parameters.new(
          groupings: {
            "0" => {
              m: "or",
              nom_cont: "Jose",
              code_beneficiaire_cont: "test"
            }
          },
          combinator: "and"
        )
        resultats = described_class.ransack(params).result
        expect(resultats).to include(beneficiaire_avec_accents)
      end
    end
  end
end
