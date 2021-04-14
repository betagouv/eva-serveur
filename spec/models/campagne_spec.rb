# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campagne, type: :model do
  it { should validate_presence_of :libelle }
  it { should validate_uniqueness_of :code }
  it { should belong_to(:questionnaire).optional }

  context 'avec des situations' do
    let(:compte) { Compte.new email: 'accompagnant@email.com', password: 'secret' }
    before do
      allow(compte).to receive(:valid?).and_return true
      Campagne::PARCOURS[:complet].each do |nom_situation|
        questionnaire = Questionnaire.new libelle: nom_situation
        situation = Situation.new libelle: nom_situation, nom_technique: nom_situation
        situation.questionnaire = questionnaire
        allow(Situation)
          .to receive(:find_by)
          .with(nom_technique: nom_situation)
          .and_return(situation)
      end
    end

    describe 'initialisation de la campagne' do
      context "n'ajoute aucune situation quand ce n'est pas demandé" do
        let(:campagne) do
          Campagne.new libelle: 'ma campagne',
                       code: 'moncode',
                       compte: compte,
                       initialise_situations: false
        end
        before { expect(campagne.valid?).to be(true) }
        it do
          campagne.save
          expect(campagne.situations_configurations.count).to eq 0
        end
      end

      context "ajoute les situations par defaut quand c'est demandé" do
        let(:campagne) do
          Campagne.new libelle: 'ma campagne',
                       code: 'moncode',
                       compte: compte,
                       modele_parcours: 'complet',
                       initialise_situations: true
        end
        before { expect(campagne.valid?).to be(true) }
        it do
          campagne.save
          expect(campagne.situations_configurations.count)
            .to eq Campagne::PARCOURS[:complet].length
        end
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
