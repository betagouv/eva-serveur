# frozen_string_literal: true

require 'rails_helper'

describe Anonymisation::Evaluation do
  describe '#anonymise' do
    let(:evaluation) { create :evaluation, email: 'toto@gmail.com', telephone: '06…' }

    it do
      described_class.new(evaluation).anonymise
      evaluation.reload
      expect(evaluation.email).to be_nil
      expect(evaluation.telephone).to be_nil
    end
  end
end
