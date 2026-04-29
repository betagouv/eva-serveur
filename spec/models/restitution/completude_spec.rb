require 'rails_helper'

describe Restitution::Completude do
  let(:completude) do
    described_class.new(evaluation, restitutions)
  end

  describe '#calcule' do
    let(:evaluation) { double(campagne_id: SecureRandom.uuid, evapro?: false) }
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
                                      .and_return([ controle.id ])
        allow(SituationConfiguration)
          .to receive(:ids_situations).with(evaluation.campagne_id,
                                            Evaluation::SITUATION_COMPETENCES_BASE)
                                      .and_return([ livraison.id ])
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

    describe "quand l'evaluation est Evapro" do
      let(:restitutions) { [] }
      let(:evaluation) { double(campagne_id: SecureRandom.uuid, evapro?: true) }

      let(:situation_diag) do
        instance_double(Situation).tap do |s|
          allow(s).to receive(:a_pour_nom_technique?)
            .with(Situation::DIAG_RISQUES_ENTREPRISE)
            .and_return(true)
          allow(s).to receive(:a_pour_nom_technique?)
            .with(Situation::EVALUATION_IMPACT_GENERAL)
            .and_return(false)
        end
      end

      let(:situation_impact) do
        instance_double(Situation).tap do |s|
          allow(s).to receive(:a_pour_nom_technique?)
            .with(Situation::DIAG_RISQUES_ENTREPRISE)
            .and_return(false)
          allow(s).to receive(:a_pour_nom_technique?)
            .with(Situation::EVALUATION_IMPACT_GENERAL)
            .and_return(true)
        end
      end

      let(:diag_restitution) do
        double(situation: situation_diag, synthese: diag_synthese)
      end

      let(:impact_restitution) do
        double(situation: situation_impact, synthese: impact_synthese)
      end

      let(:restitutions) { [ diag_restitution, impact_restitution ] }

      context 'si pourcentage_risque, score_cout et toutes les metriques impact sont presents' do
        let(:diag_synthese) { { pourcentage_risque: 25 } }
        let(:impact_synthese) do
          {
            score_cout: 'moyen',
            performance_collective: :faible,
            agilite_organisationnelle: :moyen,
            securite_qualite: :fort,
            mobilite_professionnelle: :tres_fort
          }
        end

        it 'retourne complete' do
          expect(described_class.new(evaluation, restitutions).calcule).to eq(:complete)
        end
      end

      context 'si pourcentage_risque manque' do
        let(:diag_synthese) { { pourcentage_risque: nil } }
        let(:impact_synthese) do
          {
            score_cout: 'moyen',
            performance_collective: :faible,
            agilite_organisationnelle: :moyen,
            securite_qualite: :fort,
            mobilite_professionnelle: :tres_fort
          }
        end

        it 'retourne incomplete' do
          expect(described_class.new(evaluation, restitutions).calcule).to eq(:incomplete)
        end
      end

      context 'si score_cout manque' do
        let(:diag_synthese) { { pourcentage_risque: 25 } }
        let(:impact_synthese) do
          {
            score_cout: nil,
            performance_collective: :faible,
            agilite_organisationnelle: :moyen,
            securite_qualite: :fort,
            mobilite_professionnelle: :tres_fort
          }
        end

        it 'retourne incomplete' do
          expect(described_class.new(evaluation, restitutions).calcule).to eq(:incomplete)
        end
      end

      context 'si une metrique impact manque' do
        let(:diag_synthese) { { pourcentage_risque: 25 } }
        let(:impact_synthese) do
          {
            score_cout: 'moyen',
            performance_collective: :faible,
            agilite_organisationnelle: nil,
            securite_qualite: :fort,
            mobilite_professionnelle: :tres_fort
          }
        end

        it 'retourne incomplete' do
          expect(described_class.new(evaluation, restitutions).calcule).to eq(:incomplete)
        end
      end

      context 'si diag ou impact restitution manque' do
        let(:diag_synthese) { nil }
        let(:impact_synthese) do
          {
            score_cout: 'moyen',
            performance_collective: :faible,
            agilite_organisationnelle: :moyen,
            securite_qualite: :fort,
            mobilite_professionnelle: :tres_fort
          }
        end

        it 'retourne incomplete' do
          restitutions = [ diag_restitution ].compact
          expect(described_class.new(evaluation, restitutions).calcule).to eq(:incomplete)
        end
      end
    end
  end
end
