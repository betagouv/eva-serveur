# frozen_string_literal: true

require 'rails_helper'

describe PriseEnMain do
  let(:compte) { Compte.new }
  let(:nombre_campagnes) { 1 }
  let(:nombre_evaluations) { 1 }
  let(:prise_en_main) do
    PriseEnMain.new compte: compte,
                    nombre_campagnes: nombre_campagnes,
                    nombre_evaluations: nombre_evaluations
  end

  describe '#numero_etape' do
    context "quand il n'y a pas de campagne" do
      let(:nombre_campagnes) { 0 }

      it { expect(prise_en_main.numero_etape).to eq 0 }
    end

    context "quand il n'y a pas d'évaluation et qu'il y a une campagne" do
      let(:nombre_campagnes) { 1 }
      let(:nombre_evaluations) { 0 }

      it { expect(prise_en_main.numero_etape).to eq 1 }
    end

    context "quand il y a une évaluation et qu'il y a une campagne" do
      let(:nombre_campagnes) { 1 }
      let(:nombre_evaluations) { 1 }

      it { expect(prise_en_main.numero_etape).to eq 2 }
    end
  end

  describe '#terminee?' do
    before { allow(compte).to receive(:nouveau_compte?).and_return(false) }

    context 'quand le compte est nouveau' do
      before { allow(compte).to receive(:nouveau_compte?).and_return(true) }

      it { expect(prise_en_main.terminee?).to eq false }
    end

    context "quand il n'y a pas d'évaluation" do
      let(:nombre_evaluations) { 0 }
      before { allow(compte).to receive(:nouveau_compte?).and_return(false) }

      it { expect(prise_en_main.terminee?).to eq false }
    end

    context 'quand il y a une évaluation' do
      let(:nombre_evaluations) { 1 }
      before { allow(compte).to receive(:nouveau_compte?).and_return(false) }

      it { expect(prise_en_main.terminee?).to eq false }
    end

    context "quand le compte n'est pas nouveau et qu'il y a deux évaluations" do
      let(:nombre_evaluations) { 2 }
      before { allow(compte).to receive(:nouveau_compte?).and_return(false) }

      it { expect(prise_en_main.terminee?).to eq true }
    end
  end
end
