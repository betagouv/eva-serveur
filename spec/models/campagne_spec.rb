# frozen_string_literal: true

require 'rails_helper'

describe Campagne, type: :model do
  it { should validate_presence_of :libelle }
  it { should validate_uniqueness_of(:code).case_insensitive }
  it { should belong_to(:questionnaire).optional }

  context 'avec des situations' do
    let(:parcours_type) { ParcoursType.new id: SecureRandom.uuid }
    let(:situations) do
      [:bienvenue]
    end
    let(:situation_configuration) { SituationConfiguration.new }
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
                     code: 'moncode',
                     compte: compte,
                     parcours_type: parcours_type
      end
      before do
        allow(campagne)
          .to receive(:parcours_type).and_return parcours_type
        expect(campagne.valid?).to be(true)
      end
      it do
        campagne.save
        expect(campagne.situations_configurations.count).to eq 1
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
end
