# frozen_string_literal: true

require 'rails_helper'

describe Restitution::ScoresNiveau2 do
  let(:situation_id) { double }
  let(:standardisateur) { double }

  before do
    allow(standardisateur).to receive(:standardise).and_return(nil)
  end

  context 'pas de partie' do
    it do
      scores = described_class.new([])

      expect(scores.calcule).to eq({})
    end
  end

  context 'une partie avec un score' do
    let(:partie) { double(situation_id: situation_id) }

    it do
      scores = described_class.new([ partie ],
                                   { situation_id => standardisateur })
      allow(partie).to receive(:metriques).and_return({ 'score_ccf' => 110 })
      allow(standardisateur).to receive(:standardise).with(:score_ccf, 110).and_return(1.1)
      expect(scores.calcule).to eq(score_ccf: 1.1)
    end
  end

  context "fait la moyenne des scores_niveau2 d'une liste de partie" do
    let(:partie1) { double(situation_id: situation_id) }
    let(:partie2) { double(situation_id: situation_id) }

    it do
      scores = described_class.new([ partie1, partie2 ],
                                   { situation_id => standardisateur })
      allow(partie1).to receive(:metriques).and_return({ 'score_ccf' => 110 })
      allow(partie2).to receive(:metriques).and_return({ 'score_ccf' => 120 })

      allow(standardisateur).to receive(:standardise).with(:score_ccf, 110).and_return(1.1)
      allow(standardisateur).to receive(:standardise).with(:score_ccf, 120).and_return(1.2)

      expect(scores.calcule).to eq(score_ccf: 1.15)
    end
  end

  context 'sépare les scores_niveau2 des compétences différentes' do
    let(:partie1) { double(situation_id: situation_id) }
    let(:partie2) { double(situation_id: situation_id) }

    it do
      scores = described_class.new([ partie1, partie2 ],
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

      expect(scores.calcule).to eq(score_ccf: 1.1,
                                   score_memorisation: 1.2,
                                   score_numeratie: 1.3)
    end
  end
end
