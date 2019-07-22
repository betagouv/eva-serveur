# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Questions do
  let(:question1) { build :question_qcm, intitule: 'Ma question 1' }
  let(:question2) { build :question_qcm, intitule: 'Ma question 2' }
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
end
