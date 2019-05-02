# frozen_string_literal: true

require 'rails_helper'

describe EvaluationBase do
  let(:evaluation) { described_class.new(evenements) }

  context 'lorsque le dernier événement est stop' do
    let(:evenements) do
      [
        build(:evenement_piece_bien_placee),
        build(:evenement_piece_mal_placee),
        build(:evenement_stop)
      ]
    end

    it { expect(evaluation.abandon?).to be(true) }
  end

  it 'envoie une exception not implemented pour la méthode termine?' do
    expect do
      described_class.new([]).termine?
    end.to raise_error(NotImplementedError)
  end
end
