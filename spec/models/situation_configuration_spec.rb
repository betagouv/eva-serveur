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

  describe '#auto_positionnement_inclus?' do
    context 'pas inclus' do
      let(:questionnaire) { double(nom_technique: 'autre_chose') }
      let(:situations_configurations) { [double(questionnaire: questionnaire)] }
      it do
        expect(SituationConfiguration.auto_positionnement_inclus?(situations_configurations))
          .to eq(false)
      end
    end

    context 'inclus' do
      let(:questionnaire) { double(nom_technique: Eva::QUESTIONNAIRE_AUTO_POSITIONNEMENT) }
      let(:situations_configurations) { [double(questionnaire: questionnaire)] }
      it do
        expect(SituationConfiguration.auto_positionnement_inclus?(situations_configurations))
          .to eq(true)
      end
    end
  end

  describe '#expression_ecrite_incluse?' do
    context 'pas incluse' do
      let(:questionnaire) { double(nom_technique: 'autre_chose') }
      let(:situations_configurations) { [double(questionnaire: questionnaire)] }
      it do
        expect(SituationConfiguration.expression_ecrite_incluse?(situations_configurations))
          .to eq(false)
      end
    end

    context 'incluse' do
      let(:questionnaire) { double(nom_technique: Eva::QUESTIONNAIRE_EXPRESSION_ECRITE) }
      let(:situations_configurations) { [double(questionnaire: questionnaire)] }
      it do
        expect(SituationConfiguration.expression_ecrite_incluse?(situations_configurations))
          .to eq(true)
      end
    end
  end
end
