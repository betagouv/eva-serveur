# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::InterpreteurNiveau2 do
  let(:subject) { Restitution::Illettrisme::InterpreteurNiveau2.new scores_standardises }

  context 'pas de score à interpreter' do
    let(:scores_standardises) { {} }
    it { expect(subject.interpretations).to eq [] }
  end

  context 'score ccf < à -1' do
    let(:scores_standardises) { { score_ccf: -1.01 } }
    it { expect(subject.interpretations).to include({ score_ccf: :niveau1 }) }
  end

  context '-1 < score ccf < à 0' do
    let(:scores_standardises) { { score_ccf: -1 } }
    it { expect(subject.interpretations).to include({ score_ccf: :niveau2 }) }
  end
end
