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

  describe '#etape_en_cours' do
    context "quand il n'y a pas de campagne" do
      let(:nombre_campagnes) { 0 }

      it { expect(prise_en_main.etape_en_cours).to eq 'creation_campagne' }
    end

    context "quand il n'y a pas d'évaluation et qu'il y a une campagne" do
      let(:nombre_campagnes) { 1 }
      let(:nombre_evaluations) { 0 }

      it { expect(prise_en_main.etape_en_cours).to eq 'test_campagne' }
    end

    context "quand il y a moins de 4 évaluations et qu'il y a une campagne" do
      let(:nombre_campagnes) { 1 }
      let(:nombre_evaluations) { 3 }

      it { expect(prise_en_main.etape_en_cours).to eq 'passations' }
    end

    context "quand il y a au moins 4 évaluations et qu'il y a une campagne" do
      let(:nombre_campagnes) { 1 }
      let(:nombre_evaluations) { 4 }

      it { expect(prise_en_main.etape_en_cours).to eq 'retour_experience' }
    end
  end

  describe '#terminee?' do
    before { allow(compte).to receive(:nouveau_compte?).and_return(false) }

    context 'quand le compte est nouveau' do
      before { allow(compte).to receive(:nouveau_compte?).and_return(true) }

      it { expect(prise_en_main.terminee?).to be false }
    end

    context "quand il n'y a pas d'évaluation" do
      let(:nombre_evaluations) { 0 }

      before { allow(compte).to receive(:nouveau_compte?).and_return(false) }

      it { expect(prise_en_main.terminee?).to be false }
    end

    context 'quand il y a moins de 4 évaluations' do
      let(:nombre_evaluations) { 3 }

      before { allow(compte).to receive(:nouveau_compte?).and_return(false) }

      it { expect(prise_en_main.terminee?).to be false }
    end

    context "quand le compte n'est pas nouveau et qu'il y quatre évaluations" do
      let(:nombre_evaluations) { 4 }

      before { allow(compte).to receive(:nouveau_compte?).and_return(false) }

      it { expect(prise_en_main.terminee?).to be true }
    end
  end
end
