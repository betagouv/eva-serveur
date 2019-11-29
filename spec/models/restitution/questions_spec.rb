# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Questions do
  let(:situation) { create :situation, libelle: 'Questions', nom_technique: 'questions' }
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let(:question1) { create :question_qcm, intitule: 'Ma question 1' }
  let(:question2) { create :question_qcm, intitule: 'Ma question 2' }
  let(:questionnaire) { create :questionnaire, questions: [question1, question2] }
  let(:campagne) { build :campagne, questionnaire: questionnaire }

  describe '#termine?' do
    it "lorsque aucune questions n'a encore été répondu" do
      evenements = [build(:evenement_demarrage)]
      restitution = described_class.new(campagne, evenements)
      expect(restitution).to_not be_termine
    end

    it 'lorsque une des questions a été répondu' do
      evenements = [
        build(:evenement_demarrage),
        build(:evenement_reponse, donnees: { question: question1.id, reponse: 1 })
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution).to_not be_termine
    end

    it 'lorsque les 2 questions ont été répondu' do
      evenements = [
        build(:evenement_demarrage),
        build(:evenement_reponse, donnees: { question: question1.id, reponse: 1 }),
        build(:evenement_reponse, donnees: { question: question2.id, reponse: 2 })
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution).to be_termine
    end
  end

  describe '#questions_et_reponses' do
    it "retourne aucune question et réponse si aucune n'a été répondu" do
      evenements = [
        build(:evenement_demarrage)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.questions_et_reponses.size).to eq(0)
    end

    it 'retourne les questions et les réponses du questionnaire' do
      evenements = [
        build(:evenement_demarrage, evaluation: evaluation, situation: situation),
        build(:evenement_reponse,
              evaluation: evaluation,
              situation: situation,
              donnees: { question: question1.id, reponse: 1 })
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.questions_et_reponses.size).to eq(1)
      expect(restitution.questions_et_reponses.first[:question]).to eql(question1)
      expect(restitution.questions_et_reponses.first[:reponse]).to eql(1)
    end
  end

  describe '#choix_reponse' do
    let!(:choix_question1) do
      create(:choix, intitule: 'bonne réponse', type_choix: 'bon',
                     question_id: question1.id)
    end

    it 'retourne le choix répondu' do
      evenements = [
        build(:evenement_demarrage, evaluation: evaluation, situation: situation),
        build(:evenement_reponse,
              evaluation: evaluation,
              situation: situation,
              donnees: { question: question1.id, reponse: choix_question1.id })
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.choix_repondu(question1)).to eql(choix_question1)
    end

    it "ne retourne rien si la question n'a pas été répondu" do
      evenements = [
        build(:evenement_demarrage, evaluation: evaluation, situation: situation)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.choix_repondu(question1)).to be_nil
    end
  end

  describe '#reponses' do
    it 'retourne toutes les réponses' do
      evenements = [
        build(:evenement_reponse),
        build(:evenement_reponse)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.reponses.size).to eql(2)
    end

    it 'retourne seulement les événements réponses' do
      evenements = [
        build(:evenement_demarrage),
        build(:evenement_reponse)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.reponses.size).to eql(1)
    end
  end

  describe '#efficience' do
    it 'retourne nil' do
      restitution = described_class.new(campagne, [])
      expect(restitution.efficience).to be_nil
    end
  end
end
