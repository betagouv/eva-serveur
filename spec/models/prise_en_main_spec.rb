# frozen_string_literal: true

require 'rails_helper'

describe PriseEnMain do
  let(:compte) { Compte.new }
  let(:nombre_campagnes) { 1 }
  let(:nombre_evaluations) { 1 }
  let(:prise_en_main) do
    described_class.new compte: compte,
                        nombre_campagnes: nombre_campagnes,
                        nombre_evaluations: nombre_evaluations
  end

  describe '#etape_en_cours' do
    context "Quand le compte n'a pas de structure" do
      it { expect(prise_en_main.etape_en_cours).to eq 'rejoindre_structure' }
    end

    context 'quand le compte a rejoint une structure' do
      let(:structure) { Structure.new }

      before do
        compte.structure = structure
      end

      context "et qu'il n'y a pas de campagne" do
        let(:nombre_campagnes) { 0 }

        it { expect(prise_en_main.etape_en_cours).to eq 'creation_campagne' }
      end

      context "et qu'il y a une campagne" do
        let(:nombre_campagnes) { 1 }

        context "et qu'il n'y a pas d'évaluation" do
          let(:nombre_evaluations) { 0 }

          it { expect(prise_en_main.etape_en_cours).to eq 'test_campagne' }
        end

        context "et qu'il y a au moins une évaluation" do
          let(:nombre_evaluations) { 1 }

          context "et que le compte n'est pas confirmé" do
            it { expect(prise_en_main.etape_en_cours).to eq 'confirmation_email' }
          end

          context 'et que le compte est confirmé' do
            let(:compte) { Compte.new(confirmed_at: Time.zone.now) }

            context "et qu'il y a moins de 4 passations" do
              let(:nombre_evaluations) { 3 }

              it { expect(prise_en_main.etape_en_cours).to eq 'passations' }
            end

            context "et qu'il y au moins 4 passations" do
              let(:nombre_evaluations) { 4 }

              it { expect(prise_en_main.etape_en_cours).to eq 'fin' }
            end
          end
        end
      end
    end
  end

  describe '#terminee?' do
    context 'quand le mode tutoriel est désactivé' do
      before { compte.update(mode_tutoriel: false) }

      it { expect(prise_en_main.terminee?).to be true }
    end

    context 'quand le mode tutoriel est activé' do
      before { compte.update(mode_tutoriel: true) }

      it { expect(prise_en_main.terminee?).to be false }
    end
  end
end
