# frozen_string_literal: true

require 'rails_helper'

describe SituationConfiguration do
  it do
    is_expected.to validate_uniqueness_of(:situation_id).scoped_to(%i[campagne_id parcours_type_id])
                                                        .case_insensitive
  end

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

  describe '#questionnaire_inclus?' do
    let(:situation_configuration) { SituationConfiguration.new }
    before do
      allow(situation_configuration).to receive(:questionnaire_utile).and_return questionnaire_utile
    end

    context 'quand pas inclus' do
      let(:questionnaire_utile) { double(nom_technique: 'autre_chose') }

      it do
        expect(SituationConfiguration.questionnaire_inclus?([situation_configuration],
                                                            'quelque_chose'))
          .to eq(false)
      end
    end

    context 'quand inclus' do
      let(:questionnaire_utile) { double(nom_technique: 'quelque_chose') }
      it do
        expect(SituationConfiguration.questionnaire_inclus?([situation_configuration],
                                                            'quelque_chose'))
          .to eq(true)
      end
    end

    context 'quand pas de questionnaire utile' do
      let(:questionnaire_utile) { nil }
      it do
        expect(SituationConfiguration.questionnaire_inclus?([situation_configuration],
                                                            'quelque_chose'))
          .to eq(false)
      end
    end
  end
end
