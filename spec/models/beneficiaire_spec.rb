# frozen_string_literal: true

require 'rails_helper'

describe Beneficiaire do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_uniqueness_of(:code_personnel).case_insensitive }
  it { is_expected.to allow_value('ABC1234').for(:code_personnel) }
  it { is_expected.not_to allow_value('ABC.123.').for(:code_personnel) }
  it { is_expected.not_to allow_value('abc1234').for(:code_personnel) }

  describe '#genere_code_personnel_unique' do
    let(:beneficiaire) { described_class.new nom: "Mathéo" }

    context 'genere un code personnel avec le nom du bénéficiare' do
      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_personnel_unique
      end

      it do
        expect(beneficiaire.code_personnel).to eq 'MAT1234'
      end
    end

    context "quand le nom comporte un accent" do
      let(:beneficiaire) { described_class.new nom: "Élise" }

      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_personnel_unique
      end

      it do
        expect(beneficiaire.code_personnel).to eq 'ELI1234'
      end
    end

    context "quand le nom comporte un caractère spécial" do
      let(:beneficiaire) { described_class.new nom: "E-T Lise" }

      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_personnel_unique
      end

      it do
        expect(beneficiaire.code_personnel).to eq 'ETL1234'
      end
    end

    context 'quand le code_personnel est déjà présent' do
      before do
        _beneficiaire_existant = create(:beneficiaire, code_personnel: 'MAT1234')
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234).and_return(8080)
        beneficiaire.genere_code_personnel_unique
      end

      it { expect(beneficiaire.code_personnel).to eq 'MAT8080' }
    end
  end
end
