require 'rails_helper'

describe 'evaluations:recalcule_completude_positionnement' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }

  let!(:place_du_marche) { create :situation_place_du_marche }
  let!(:livraison) { create :situation_livraison }

  before { allow(logger).to receive(:info) }

  context "quand une évaluation a une partie sur une situation de positionnement" do
    let!(:evaluation) { create :evaluation, :eva }
    let!(:partie) { create :partie, evaluation: evaluation, situation: place_du_marche }

    it "recalcule et persiste sa restitution globale" do
      restitution_globale = double(persiste: true)
      expect(FabriqueRestitution).to receive(:restitution_globale)
        .with(evaluation).and_return(restitution_globale)

      subject.invoke
    end
  end

  context "quand une évaluation n'a aucune partie sur une situation de positionnement" do
    let!(:evaluation) { create :evaluation, :eva }
    let!(:partie) { create :partie, evaluation: evaluation, situation: livraison }

    it "ne recalcule pas sa restitution globale" do
      expect(FabriqueRestitution).not_to receive(:restitution_globale)

      subject.invoke
    end
  end
end
