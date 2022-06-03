# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Evacob::ScoreModule do
  let(:evenements) do
    [build(:evenement_demarrage)] + evenements_reponses
  end

  describe 'metrique score_orientation' do
    let(:metrique_score_reponse_orientation) do
      described_class.new.calcule(evenements_decores(evenements, :evacob), :orientation)
    end
    let(:question_lodi1) { 'LOdi1' }
    let(:question_lodi2) { 'LOdi2' }

    context 'somme les scores des réponses' do
      let(:evenements_reponses) do
        [
          build(:evenement_affichage_question_qcm, donnees: { question: question_lodi1 }),
          build(:evenement_reponse, donnees: { question: question_lodi1, score: 1 }),
          build(:evenement_affichage_question_qcm, donnees: { question: question_lodi2 }),
          build(:evenement_reponse, donnees: { question: question_lodi2, score: 2.5 }),
          build(:evenement_reponse, donnees: { question: 'autre_question', score: 100 }),
          build(:evenement, donnees: { score: 100 })
        ]
      end

      it { expect(metrique_score_reponse_orientation).to eq(3.5) }
    end

    context 'avec une réponse sans score' do
      let(:evenements_reponses) do
        [build(:evenement_reponse, donnees: { question: question_lodi1 })]
      end

      it { expect(metrique_score_reponse_orientation).to eq(0) }
    end
  end
end
