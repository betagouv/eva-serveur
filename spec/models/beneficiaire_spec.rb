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

    context 'genere un code bénéficiaire avec le nom du bénéficiare' do
      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_beneficiaire_unique
      end

      it do
        expect(beneficiaire.code_beneficiaire).to eq 'MAT1234'
      end
    end

    context "quand le nom comporte un accent" do
      let(:beneficiaire) { described_class.new nom: "Élise" }

      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_beneficiaire_unique
      end

      it do
        expect(beneficiaire.code_beneficiaire).to eq 'ELI1234'
      end
    end

    context "quand le nom comporte un caractère spécial" do
      let(:beneficiaire) { described_class.new nom: "E-T Lise" }

      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_beneficiaire_unique
      end

      it do
        expect(beneficiaire.code_beneficiaire).to eq 'ETL1234'
      end
    end

    context 'quand le code_beneficiaire est déjà présent' do
      before do
        _beneficiaire_existant = create(:beneficiaire, code_beneficiaire: 'MAT1234')
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234).and_return(8080)
        beneficiaire.genere_code_beneficiaire_unique
      end

      it { expect(beneficiaire.code_beneficiaire).to eq 'MAT8080' }
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
