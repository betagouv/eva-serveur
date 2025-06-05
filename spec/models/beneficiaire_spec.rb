# frozen_string_literal: true

require 'rails_helper'

describe Beneficiaire do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to allow_value('ABC1234').for(:code) }
  it { is_expected.not_to allow_value('ABC.123.').for(:code) }
  it { is_expected.not_to allow_value('abc1234').for(:code) }

  describe '#genere_code_unique' do
    let(:beneficiaire) { Beneficiaire.new nom: "Mathéo" }

    context 'genere un code avec le nom du bénéficiare' do
      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_unique
      end

      it do
        expect(beneficiaire.code).to eq 'MAT1234'
      end
    end

    context "quand le nom comporte un accent" do
      let(:beneficiaire) { Beneficiaire.new nom: "Élise" }

      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_unique
      end

      it do
        expect(beneficiaire.code).to eq 'ELI1234'
      end
    end

    context "quand le nom comporte un caractère spécial" do
      let(:beneficiaire) { Beneficiaire.new nom: "E-T Lise" }

      before do
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234)
        beneficiaire.genere_code_unique
      end

      it do
        expect(beneficiaire.code).to eq 'ETL1234'
      end
    end

    context 'quand le code est déjà présent' do
      before do
        _beneficiaire_existant = create(:beneficiaire, code: 'MAT1234')
        allow(GenerateurAleatoire).to receive(:nombres).and_return(1234).and_return(8080)
        beneficiaire.genere_code_unique
      end

      it { expect(beneficiaire.code).to eq 'MAT8080' }
    end
  end
end
