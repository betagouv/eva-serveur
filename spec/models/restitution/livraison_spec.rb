# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Livraison do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let(:question1)  { create :question_qcm, intitule: 'Ma question 1' }
  let(:question2)  { create :question_qcm, intitule: 'Ma question 2' }
  let(:questionnaire) { create :questionnaire, questions: [question1, question2] }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:situation) do
    create :situation,
           libelle: 'Livraison',
           nom_technique: 'livraison',
           questionnaire: questionnaire
  end
  let(:campagne) { build :campagne }

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

    it "avec l'événement de fin de situation" do
      evenements = [
        build(:evenement_demarrage),
        build(:evenement_fin_situation)
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
        build(:evenement_demarrage),
        build(:evenement_reponse,
              donnees: { question: question1.id, reponse: 1 })
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.questions_et_reponses.size).to eq(1)
      expect(restitution.questions_et_reponses.first[:question]).to eql(question1)
      expect(restitution.questions_et_reponses.first[:reponse]).to eql(1)
    end
  end

  describe '#reponses' do
    it 'retourne toutes les réponses' do
      evenements = [
        build(:evenement_demarrage),
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

  describe '#nombre_bonnes_reponses' do
    let(:question3) { create :question_qcm, intitule: 'Ma question 3' }

    let(:bon_choix) do
      create :choix, type_choix: :bon, question_id: question1.id, intitule: 'bon'
    end

    let(:mauvais_choix) do
      create :choix, type_choix: :mauvais, question_id: question2.id, intitule: 'mauvais'
    end

    let(:abstention_choix) do
      create :choix, type_choix: :abstention, question_id: question3.id, intitule: 'abstention'
    end

    context "pas d'événements réponse" do
      it 'retourne nil' do
        evenements = [
          build(:evenement_demarrage)
        ]

        restitution = described_class.new(campagne, evenements)
        expect(restitution.nombre_bonnes_reponses).to eq(0)
      end
    end

    context 'avec une bonne réponse' do
      it do
        evenements = [
          build(:evenement_demarrage),
          build(:evenement_reponse,
                donnees: { question: question1.id, reponse: bon_choix.id })
        ]
        restitution = described_class.new(campagne, evenements)
        expect(restitution.nombre_bonnes_reponses).to eq(1)
      end
    end

    context 'avec des réponses autre que bonnes' do
      it do
        evenements = [
          build(:evenement_demarrage),
          build(:evenement_reponse,
                donnees: { question: question2.id, reponse: mauvais_choix.id }),
          build(:evenement_reponse,
                donnees: { question: question3.id, reponse: abstention_choix.id })
        ]
        restitution = described_class.new(campagne, evenements)
        expect(restitution.nombre_bonnes_reponses).to eq(0)
      end
    end
  end
end
