# frozen_string_literal: true

require 'rails_helper'

describe Campagne, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to allow_value('ABCD1234').for(:code) }
  it { is_expected.not_to allow_value('ABC.123.').for(:code) }
  it { is_expected.not_to allow_value('abcd1234').for(:code) }

  context 'quand une campagne a été soft-delete' do
    let(:compte) { create :compte }
    let(:campagne) { build :campagne, compte: compte, code: 'XY234' }

    before do
      campagne_existante_effacee = create :campagne, libelle: 'effacée', compte: compte,
                                                     code: 'XY234'
      campagne_existante_effacee.destroy
    end

    it "Ne retourne pas d'erreur PostgreSQL" do
      expect(campagne.save).to be false
    end
  end

  describe 'scopes' do
    describe '.de_la_structure' do
      subject(:campagnes) { described_class.de_la_structure(compte.structure) }

      let(:compte) { create :compte }
      let(:autre_compte) { create :compte }
      let(:autre_campagne) { create :campagne, compte: autre_compte }

      let!(:campagne_non_active) { create :campagne, libelle: 'non active', compte: compte }
      let(:campagne_moins_active) { create :campagne, libelle: 'moins active', compte: compte }
      let(:campagne_active) { create :campagne, libelle: 'active', compte: compte }
      let!(:evaluation_recente) do
        create :evaluation, campagne: campagne_active,
                            created_at: Time.zone.local(2020, 1, 1, 12, 0, 21)
      end
      let!(:evaluation_pas_recente) do
        create :evaluation, campagne: campagne_moins_active,
                            created_at: Time.zone.local(2020, 1, 1, 12, 0, 20)
      end

      it "retourne les campagnes d'une structure par ordre d'activité" do
        expect(campagnes.all.map(&:libelle)).to eql ['active', 'moins active', 'non active']
      end

      it "retourne le nombre d'évaluations pour une campagne" do
        expect(campagnes.first.nombre_evaluations).to eq(1)
      end

      it 'retourne la date de la dernière évaluation pour une campagne' do
        expect(campagnes.first.date_derniere_evaluation).to eq(evaluation_recente.created_at)
      end
    end
  end

  describe '#questionnaire_pour' do
    let(:campagne) { described_class.new }
    let(:situation) { Situation.new }

    def bouchonne_config_situation(situation_configuration)
      allow(campagne.situations_configurations)
        .to receive(:find_by).with(situation: situation).and_return situation_configuration
    end

    context 'sans configuration pour la situation' do
      let(:questionnaire_par_default) { double }

      before do
        bouchonne_config_situation(nil)
        allow(situation).to receive(:questionnaire).and_return(questionnaire_par_default)
      end

      it { expect(campagne.questionnaire_pour(situation)).to eq questionnaire_par_default }
    end

    context 'avec configuration pour la situation' do
      let(:questionnaire) { double }
      let(:situation_configuration) { double(questionnaire_utile: questionnaire) }

      before { bouchonne_config_situation(situation_configuration) }

      it { expect(campagne.questionnaire_pour(situation)).to eq questionnaire }
    end
  end

  describe '#avec_competences_transversales?' do
    let(:campagne) { described_class.new }
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

  describe '#genere_code_unique' do
    let(:compte) { create :compte }
    let(:campagne) { build :campagne, compte: compte, code: nil }

    before do
      allow(GenerateurAleatoire).to receive(:majuscules).with(3).and_return 'XXX'
    end

    context 'genere un code avec le code postal de la structure' do
      before do
        allow(compte).to receive(:structure_code_postal).and_return '75012'
        campagne.genere_code_unique
      end

      it do
        expect(campagne.code).to eq 'XXX75012'
      end
    end

    context "quand il n'y a pas de compte" do
      before do
        campagne.compte = nil
        campagne.genere_code_unique
      end

      it { expect(campagne.code).to be_nil }
    end

    context 'quand le code est déjà présent' do
      before do
        campagne.code = '123'
        campagne.genere_code_unique
      end

      it { expect(campagne.code).to eq '123' }
    end
  end
end
