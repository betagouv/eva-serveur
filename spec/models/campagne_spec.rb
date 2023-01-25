# frozen_string_literal: true

require 'rails_helper'

describe Campagne, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to allow_value('ABCD1234').for(:code) }
  it { is_expected.not_to allow_value('ABC.123.').for(:code) }
  it { is_expected.not_to allow_value('abcd1234').for(:code) }

  describe '#questionnaire_pour' do
    let(:campagne) { Campagne.new }
    let(:situation) { Situation.new }

    def bouchonne_config_situation(situation_configuration)
      allow(campagne.situations_configurations)
        .to receive(:find_by).with(situation: situation).and_return situation_configuration
    end

    context 'sans configuration pour la situation' do
      before { bouchonne_config_situation(nil) }

      it { expect(campagne.questionnaire_pour(situation)).to be_nil }
    end

    context 'avec configuration pour la situation' do
      let(:questionnaire) { double }
      let(:situation_configuration) { double(questionnaire_utile: questionnaire) }

      before { bouchonne_config_situation(situation_configuration) }

      it { expect(campagne.questionnaire_pour(situation)).to eq questionnaire }
    end
  end

  describe '#avec_competences_transversales?' do
    let(:campagne) { Campagne.new }
    let(:maintenance) { create :situation, nom_technique: :maintenance }

    context 'sans situation' do
      it { expect(campagne.avec_competences_transversales?).to be false }
    end

    context 'sans situation de compétences transversale' do
      before do
        campagne.situations_configurations
                .push SituationConfiguration.new situation: maintenance
      end

      it { expect(campagne.avec_competences_transversales?).to be false }
    end

    context 'avec une situation de compétences transversale' do
      let!(:tri) { create :situation, nom_technique: :tri }

      before do
        campagne.situations_configurations
                .push SituationConfiguration.new situation: maintenance
        campagne.situations_configurations.push SituationConfiguration.new situation: tri
      end

      it { expect(campagne.avec_competences_transversales?).to be true }
    end
  end
end
