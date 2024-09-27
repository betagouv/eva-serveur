# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Completude do
  let(:completude) do
    described_class.new(evaluation, restitutions)
  end

  describe '#calcule' do
    let(:evaluation) { double(campagne_id: SecureRandom.uuid) }
    let(:bienvenue) { Situation.new id: SecureRandom.uuid }
    let(:plan_de_la_ville) { Situation.new id: SecureRandom.uuid }
    let(:controle) { Situation.new id: SecureRandom.uuid }
    let(:livraison) { Situation.new id: SecureRandom.uuid }
    let(:maintenance) { Situation.new id: SecureRandom.uuid }
    let(:objets_trouves) { Situation.new id: SecureRandom.uuid }

    describe 'quand la campagne est complete' do
      before do
        allow(SituationConfiguration)
          .to receive(:ids_situations).with(evaluation.campagne_id,
                                            Evaluation::SITUATION_COMPETENCES_TRANSVERSALES)
                                      .and_return([controle.id])
        allow(SituationConfiguration)
          .to receive(:ids_situations).with(evaluation.campagne_id,
                                            Evaluation::SITUATION_COMPETENCES_BASE)
                                      .and_return([livraison.id])
      end

      context "quand aucune situations n'a été complétée" do
        let(:restitutions) { [] }

        it { expect(completude.calcule).to eq :incomplete }
      end

      context 'quand toutes les situations de la campagne ont été complétées' do
        let(:restitutions) do
          [
            double(situation: bienvenue, termine?: true),
            double(situation: plan_de_la_ville, termine?: true),
            double(situation: controle, termine?: true),
            double(situation: livraison, termine?: true)
          ]
        end

        it { expect(completude.calcule).to eq :complete }
      end

      context "quand une situations non évaluante n'est pas terminée" do
        let(:restitutions) do
          [
            double(situation: bienvenue, termine?: false),
            double(situation: plan_de_la_ville, termine?: true),
            double(situation: controle, termine?: true),
            double(situation: livraison, termine?: true)
          ]
        end

        it { expect(completude.calcule).to eq :complete }
      end

      context "quand une même situation n'est pas terminée" do
        let(:restitutions) do
          [
            double(situation: bienvenue, termine?: true),
            double(situation: plan_de_la_ville, termine?: true),
            double(situation: controle, termine?: false),
            double(situation: controle, termine?: false),
            double(situation: livraison, termine?: true)
          ]
        end

        it { expect(completude.calcule).not_to eq :complete }
      end

      context 'quand une même situation se termine après plusieurs essai' do
        let(:restitutions) do
          [
            double(situation: bienvenue, termine?: true),
            double(situation: plan_de_la_ville, termine?: true),
            double(situation: controle, termine?: false),
            double(situation: controle, termine?: true),
            double(situation: livraison, termine?: true)
          ]
        end

        it { expect(completude.calcule).to eq :complete }
      end

      context 'quand situation competence transversale non terminée' do
        let(:restitutions) do
          [
            double(situation: bienvenue, termine?: true),
            double(situation: plan_de_la_ville, termine?: true),
            double(situation: controle, termine?: false),
            double(situation: livraison, termine?: true)
          ]
        end

        it { expect(completude.calcule).to eq :competences_transversales_incompletes }
      end

      context 'quand situation competence de base non terminée' do
        let(:restitutions) do
          [
            double(situation: bienvenue, termine?: true),
            double(situation: plan_de_la_ville, termine?: true),
            double(situation: controle, termine?: true),
            double(situation: livraison, termine?: false)
          ]
        end

        it { expect(completude.calcule).to eq :competences_de_base_incompletes }
      end
    end

    describe 'quand la campagne est avec competences de base seulement' do
      before do
        allow(SituationConfiguration)
          .to receive(:ids_situations).with(evaluation.campagne_id,
                                            Evaluation::SITUATION_COMPETENCES_TRANSVERSALES)
                                      .and_return([])
        allow(SituationConfiguration)
          .to receive(:ids_situations).with(evaluation.campagne_id,
                                            Evaluation::SITUATION_COMPETENCES_BASE)
                                      .and_return([
                                                    livraison.id,
                                                    maintenance.id,
                                                    objets_trouves.id
                                                  ])
      end

      context 'quand toutes les situations de la campagne ont été complétées' do
        let(:restitutions) do
          [
            double(situation: maintenance, termine?: true),
            double(situation: livraison, termine?: true),
            double(situation: objets_trouves, termine?: true)
          ]
        end

        it { expect(completude.calcule).to eq :complete }
      end

      context "quand une situations de la campagne n'a pas été complétée" do
        let(:restitutions) do
          [
            double(situation: maintenance, termine?: true),
            double(situation: livraison, termine?: true),
            double(situation: objets_trouves, termine?: false)
          ]
        end

        it { expect(completude.calcule).to eq :incomplete }
      end
    end

    describe 'quand la campagne est avec competences transversales seulement' do
      before do
        allow(SituationConfiguration)
          .to receive(:ids_situations).with(evaluation.campagne_id,
                                            Evaluation::SITUATION_COMPETENCES_TRANSVERSALES)
                                      .and_return([
                                                    controle.id
                                                  ])
        allow(SituationConfiguration)
          .to receive(:ids_situations).with(evaluation.campagne_id,
                                            Evaluation::SITUATION_COMPETENCES_BASE)
                                      .and_return([])
      end

      context 'quand toutes les situations de la campagne ont été complétées' do
        let(:restitutions) do
          [
            double(situation: controle, termine?: true)
          ]
        end

        it { expect(completude.calcule).to eq :complete }
      end

      context "quand une situations de la campagne n'a pas été complétée" do
        let(:restitutions) do
          [
            double(situation: controle, termine?: false)
          ]
        end

        it { expect(completude.calcule).to eq :incomplete }
      end
    end
  end
end
