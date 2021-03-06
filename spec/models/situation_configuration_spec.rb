# frozen_string_literal: true

require 'rails_helper'

describe SituationConfiguration do
  it { should validate_uniqueness_of(:situation_id).scoped_to(:campagne_id).case_insensitive }

  describe '#questionnaire_utile' do
    let(:situation_configuree) { described_class.new }
    let(:questionnaire_situation) { double }
    let(:situation) { double questionnaire: questionnaire_situation }
    before { allow(situation_configuree).to receive(:situation).and_return situation }

    context 'sans surcharge' do
      before { situation_configuree.questionnaire = nil }
      it { expect(situation_configuree.questionnaire_utile).to eq questionnaire_situation }
    end

    context 'avec surcharge' do
      let(:questionnaire_surcharge) { Questionnaire.new }
      before { situation_configuree.questionnaire = questionnaire_surcharge }
      it { expect(situation_configuree.questionnaire_utile).to eq questionnaire_surcharge }
    end
  end
end
