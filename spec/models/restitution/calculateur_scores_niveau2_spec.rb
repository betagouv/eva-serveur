# frozen_string_literal: true

require 'rails_helper'

describe Restitution::CalculateurScoresNiveau2 do
  describe '#calcule_scores_niveau2' do
    let(:situation_id) { double }
    let(:standardisateur) { double }

    before do
      allow(standardisateur).to receive(:standardise).and_return(nil)
    end

    context 'pas de partie' do
      it do
        calculateur = Restitution::CalculateurScoresNiveau2.new([])

        expect(calculateur.scores_niveau2).to eq({})
      end
    end

    context 'une partie avec un score' do
      let(:partie) { double(situation_id: situation_id) }

      it do
        calculateur = Restitution::CalculateurScoresNiveau2.new([partie],
                                                                { situation_id => standardisateur })
        allow(partie).to receive(:metriques).and_return({ 'score_ccf' => 110 })
        allow(standardisateur).to receive(:standardise).with(:score_ccf, 110).and_return(1.1)
        expect(calculateur.scores_niveau2).to eq(score_ccf: 1.1)
      end
    end

    context "fait la moyenne des scores_niveau2 d'une liste de partie" do
      let(:partie1) { double(situation_id: situation_id) }
      let(:partie2) { double(situation_id: situation_id) }
      it do
        calculateur = Restitution::CalculateurScoresNiveau2.new([partie1, partie2],
                                                                { situation_id => standardisateur })
        allow(partie1).to receive(:metriques).and_return({ 'score_ccf' => 110 })
        allow(partie2).to receive(:metriques).and_return({ 'score_ccf' => 120 })

        allow(standardisateur).to receive(:standardise).with(:score_ccf, 110).and_return(1.1)
        allow(standardisateur).to receive(:standardise).with(:score_ccf, 120).and_return(1.2)

        expect(calculateur.scores_niveau2).to eq(score_ccf: 1.15)
      end
    end

    context 'sépare les scores_niveau2 des compétences différentes' do
      let(:partie1) { double(situation_id: situation_id) }
      let(:partie2) { double(situation_id: situation_id) }

      it do
        calculateur = Restitution::CalculateurScoresNiveau2.new([partie1, partie2],
                                                                { situation_id => standardisateur })
        allow(partie1).to receive(:metriques)
          .and_return({ 'score_ccf' => 110, 'score_memorisation' => 120 })
        allow(partie2).to receive(:metriques).and_return({ 'score_numeratie' => 130 })

        allow(standardisateur).to receive(:standardise)
          .with(:score_ccf, 110)
          .and_return(1.1)
        allow(standardisateur).to receive(:standardise)
          .with(:score_memorisation, 120)
          .and_return(1.2)
        allow(standardisateur).to receive(:standardise)
          .with(:score_numeratie, 130)
          .and_return(1.3)

        expect(calculateur.scores_niveau2).to eq(score_ccf: 1.1,
                                                 score_memorisation: 1.2,
                                                 score_numeratie: 1.3)
      end
    end
  end

  describe '#scores_niveau2_standardises' do
    let(:standardisateur_niveau2) { double }

    let(:calculateur_scores_niveau2) do
      Restitution::CalculateurScoresNiveau2.new(nil)
    end

    context 'pas de scores de niveau2' do
      it do
        allow(calculateur_scores_niveau2).to receive(:scores_niveau2).and_return({})

        expect(calculateur_scores_niveau2.scores_niveau2_standardises).to eq({})
      end
    end

    context 'une restitution avec un score de niveau 2' do
      it do
        allow(calculateur_scores_niveau2).to receive(:standardisateur_niveau2)
          .and_return(standardisateur_niveau2)
        allow(calculateur_scores_niveau2).to receive(:scores_niveau2).and_return(score_ccf: 110)
        allow(standardisateur_niveau2).to receive(:standardise)
          .with(:score_ccf, 110).and_return(1.1)

        expect(calculateur_scores_niveau2.scores_niveau2_standardises).to eq(score_ccf: 1.1)
      end
    end
  end
end
