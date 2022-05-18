# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::ScoreOrientation do
  let(:metrique_score_reponse_orientation) do
    described_class.new.calcule(evenements_decores(evenements, :evacob), 'toutes')
  end
  let(:evenements) do
    [build(:evenement_demarrage)] + evenements_reponses
  end

  describe 'metrique score_orientation' do
    let(:question_lodi) { Restitution::MetriquesHelper::QUESTION[:LODI] }

    context 'avec une réponse avec score' do
      let(:evenements_reponses) do
        [build(:evenement_reponse,
               donnees: { question: question_lodi, score: 1 })]
      end

      it { expect(metrique_score_reponse_orientation).to eq(1) }
    end

    context 'avec une réponse sans score' do
      let(:evenements_reponses) do
        [build(:evenement_reponse,
               donnees: { question: 'LOdi2' })]
      end

      it { expect(metrique_score_reponse_orientation).to eq(0) }
    end
  end
end
