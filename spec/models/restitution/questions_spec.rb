# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Questions do
  let(:situation)  { create :situation, libelle: 'Questions', nom_technique: 'questions' }
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let(:question1)  { create :question_qcm, intitule: 'Ma question 1' }
  let(:question2)  { create :question_qcm, intitule: 'Ma question 2' }
  let(:questionnaire) { create :questionnaire, questions: [question1, question2] }
  let(:campagne) { build :campagne, questionnaire: questionnaire }

  describe '#termine?' do
    it "lorsque aucune questions n'a encore été répondu" do
      evenements = [build(:evenement_demarrage)]
      restitution = described_class.new(campagne, evenements)
      expect(restitution).not_to be_termine
    end

    it 'lorsque une des questions a été répondu' do
      evenements = [
        build(:evenement_demarrage),
        build(:evenement_reponse, donnees: { question: question1.id, reponse: 1 })
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution).not_to be_termine
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

    it "avec l'événement de fin de situation" do
      evenements = [
        build(:evenement_demarrage),
        build(:evenement_fin_situation)
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution).to be_termine
    end
  end

  describe '#efficience' do
    it 'retourne nil' do
      restitution = described_class.new(campagne, [])
      expect(restitution.efficience).to be_nil
    end
  end
end
