# frozen_string_literal: true

require 'rails_helper'

describe Campagne, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to allow_value('ABCD1234').for(:code) }
  it { is_expected.not_to allow_value('ABC.123.').for(:code) }
  it { is_expected.not_to allow_value('abcd1234').for(:code) }
  it { is_expected.to belong_to(:questionnaire).optional }

  context 'avec des situations' do
    let(:parcours_type) { ParcoursType.new id: SecureRandom.uuid }
    let(:situations) { [:bienvenue] }
    let(:situation_configuration) do
      SituationConfiguration.new situation: situation, questionnaire: questionnaire
    end
    let!(:situation) { create :situation }
    let!(:questionnaire) { create :questionnaire }
    let(:compte) { Compte.new email: 'accompagnant@email.com', password: 'secret' }

    before do
      allow(compte).to receive(:valid?).and_return true
      situations.each do |nom_situation|
        questionnaire = Questionnaire.new libelle: nom_situation
        situation = Situation.new libelle: nom_situation, nom_technique: nom_situation
        situation.questionnaire = questionnaire
        allow(parcours_type)
          .to receive(:situations_configurations).and_return [situation_configuration]
      end
    end

    describe 'initialisation de la campagne' do
      let(:campagne) do
        Campagne.new libelle: 'ma campagne',
                     code: 'COD35012',
                     compte: compte,
                     parcours_type: parcours_type
      end

      it do
        allow(campagne)
          .to receive(:parcours_type).and_return parcours_type
        expect(campagne.valid?).to be(true)
        campagne.save
        expect(campagne.situations_configurations.count).to eq 1
        expect(campagne.situations_configurations.first.questionnaire_id).to eq questionnaire.id
        expect(campagne.situations_configurations.first.situation_id).to eq situation.id
      end
    end
  end

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
