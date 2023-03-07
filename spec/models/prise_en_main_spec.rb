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

    context "quand il y a moins de 4 évaluations, qu'il y a une campagne
      mais que le compte n'est pas confirmé" do
      let(:nombre_campagnes) { 1 }
      let(:nombre_evaluations) { 3 }

      it { expect(prise_en_main.etape_en_cours).to eq 'confirmation_email' }
    end

    context 'quand le compte est confirmé' do
      let(:nombre_campagnes) { 1 }
      let(:nombre_evaluations) { 3 }
      let(:compte) { Compte.new(confirmed_at: Time.zone.now) }

      it { expect(prise_en_main.etape_en_cours).to eq 'passations' }
    end
  end

  describe '#terminee?' do
    context "quand il n'y a pas d'évaluation" do
      let(:nombre_evaluations) { 0 }

      it { expect(prise_en_main.terminee?).to be false }
    end

    context 'quand il y a moins de 4 évaluations' do
      let(:nombre_evaluations) { 3 }

      it { expect(prise_en_main.terminee?).to be false }
    end

    context 'quand il y a au moins quatre évaluations et que le mode tutoriel est désactivé' do
      let(:nombre_evaluations) { 4 }

      before { compte.update(mode_tutoriel: false) }

      it { expect(prise_en_main.terminee?).to be true }
    end
  end
end
