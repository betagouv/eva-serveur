# frozen_string_literal: true

require 'rails_helper'

describe Anonymisation::Evaluation do
  describe '#anonymise' do
    let(:evaluation) { create :evaluation, nom: 'toto', email: 'toto@gmail.com', telephone: '06…' }

    it 'anonymise avec un nom généré' do
      allow(FFaker::NameFR).to receive(:name).and_return('tata')
      described_class.new(evaluation).anonymise
      evaluation.reload
      expect(evaluation.nom).to eq 'tata'
      expect(evaluation.email).to be_nil
      expect(evaluation.telephone).to be_nil
    end

    it 'anonymise avec le nom donné' do
      described_class.new(evaluation).anonymise('nouveau nom')
      evaluation.reload
      expect(evaluation.nom).to eq 'nouveau nom'
      expect(evaluation.email).to be_nil
      expect(evaluation.telephone).to be_nil
    end
  end
end
