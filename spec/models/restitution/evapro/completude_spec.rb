require 'rails_helper'

describe Restitution::Evapro::Completude do
  let(:completude) do
    described_class.new(evaluation, restitutions)
  end

  describe '#calcule' do
    let(:evaluation) { create(:evaluation, :evapro) }
    let(:diag_risques_entreprise) { Situation.new id: SecureRandom.uuid }
    let(:evaluation_impact_general) { Situation.new id: SecureRandom.uuid }

    before do
      allow(SituationConfiguration)
        .to receive(:ids_situations)
          .with(evaluation.campagne_id, EvaluationEvapro::SITUATION_COMPETENCES_EVAPRO)
          .and_return([
            diag_risques_entreprise.id,
            evaluation_impact_general.id
          ])
    end

    context "quand aucune situations n'a été complétée" do
      let(:restitutions) do
        [
          double(situation: diag_risques_entreprise, termine?: false),
          double(situation: evaluation_impact_general, termine?: false)
        ]
      end

      it { expect(completude.calcule).to eq :incomplete }
    end

    context 'quand toutes les situations de la campagne ont été complétées' do
      let(:restitutions) do
        [
          double(situation: diag_risques_entreprise, termine?: true),
          double(situation: evaluation_impact_general, termine?: true)
        ]
      end

      it { expect(completude.calcule).to eq :complete }
    end

    context "quand une situations de la campagne n'a pas été complétée" do
      let(:restitutions) do
        [
          double(situation: diag_risques_entreprise, termine?: false),
          double(situation: evaluation_impact_general, termine?: true)
        ]
      end

      it { expect(completude.calcule).to eq :incomplete }
    end

    context "quand la campagne n'a aucune situation evapro configurée" do
      before do
        allow(SituationConfiguration)
          .to receive(:ids_situations)
            .with(evaluation.campagne_id, EvaluationEvapro::SITUATION_COMPETENCES_EVAPRO)
            .and_return([])
      end

      let(:restitutions) { [] }

      it { expect(completude.calcule).to eq :complete }
    end
  end
end
