require 'rails_helper'

describe Restitution::Eva::Completude do
  let(:completude) do
    described_class.new(evaluation, restitutions)
  end

  describe '#calcule' do
    let(:bienvenue) { create(:situation_bienvenue) }
    let(:plan_de_la_ville) { create(:situation_plan_de_la_ville) }
    let(:controle) { create(:situation_controle) }
    let(:livraison) { create(:situation_livraison) }
    let(:maintenance) { create(:situation_maintenance) }
    let(:objets_trouves) { create(:situation_objets_trouves) }
    let(:place_du_marche) { create(:situation_place_du_marche) }
    let(:evaluation) { create(:evaluation, :eva) }

    describe 'quand la campagne est complete' do
      before do
        create(:situation_configuration, campagne_id: evaluation.campagne_id, situation: controle)
        create(:situation_configuration, campagne_id: evaluation.campagne_id, situation: livraison)
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
        create(:situation_configuration, campagne_id: evaluation.campagne_id, situation: livraison)
        create(:situation_configuration,
               campagne_id: evaluation.campagne_id, situation: maintenance)
        create(:situation_configuration,
               campagne_id: evaluation.campagne_id, situation: objets_trouves)
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
        create(:situation_configuration, campagne_id: evaluation.campagne_id, situation: controle)
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

    describe 'quand la campagne est un positionnement' do
      before do
        create(:situation_configuration,
               campagne_id: evaluation.campagne_id, situation: place_du_marche)
      end

      context "quand la situation de positionnement n'a pas été complétée" do
        let(:restitutions) do
          [
            double(situation: place_du_marche, termine?: false)
          ]
        end

        it { expect(completude.calcule).to eq :incomplete }
      end

      context 'quand la situation de positionnement a été complétée' do
        let(:restitutions) do
          [
            double(situation: place_du_marche, termine?: true)
          ]
        end

        it { expect(completude.calcule).to eq :complete }
      end
    end
  end
end
