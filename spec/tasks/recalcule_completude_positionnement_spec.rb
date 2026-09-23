require 'rails_helper'

describe 'evaluations:recalcule_completude_positionnement' do
  include_context 'rake'
  let(:logger) { RakeLogger.logger }

  let!(:place_du_marche) { create :situation_place_du_marche }
  let!(:livraison) { create :situation_livraison }
  let(:campagne_positionnement) do
    create :campagne, situations_configurations: [
      build(:situation_configuration, situation: place_du_marche)
    ]
  end
  let(:campagne_diagnostic) do
    create :campagne, situations_configurations: [
      build(:situation_configuration, situation: livraison)
    ]
  end

  before { allow(logger).to receive(:info) }

  context "quand la campagne de l'évaluation propose une situation de positionnement" do
    context "et que l'évaluation est marquée complète" do
      let!(:evaluation) do
        create :evaluation, :eva, campagne: campagne_positionnement, completude: :complete
      end

      it "recalcule et persiste uniquement sa complétude" do
        restitution_globale = double
        expect(FabriqueRestitution).to receive(:restitution_globale)
          .with(evaluation).and_return(restitution_globale)
        expect(restitution_globale).to receive(:persiste_completude)

        subject.invoke
      end
    end

    context "et que l'évaluation est marquée compétences transversales incomplètes" do
      let!(:evaluation) do
        create :evaluation, :eva, campagne: campagne_positionnement,
                                  completude: :competences_transversales_incompletes
      end

      it "recalcule sa complétude" do
        expect(FabriqueRestitution).to receive(:restitution_globale)
          .with(evaluation).and_return(double(persiste_completude: true))

        subject.invoke
      end
    end

    context "et que l'évaluation est déjà marquée incomplète" do
      let!(:evaluation) do
        create :evaluation, :eva, campagne: campagne_positionnement, completude: :incomplete
      end

      it "ne recalcule pas sa complétude, le correctif ne pouvant que la dégrader" do
        expect(FabriqueRestitution).not_to receive(:restitution_globale)

        subject.invoke
      end
    end
  end

  context "quand la campagne de l'évaluation ne propose aucune situation de positionnement" do
    let!(:evaluation) do
      create :evaluation, :eva, campagne: campagne_diagnostic, completude: :complete
    end

    it "ne recalcule pas sa complétude" do
      expect(FabriqueRestitution).not_to receive(:restitution_globale)

      subject.invoke
    end
  end
end
