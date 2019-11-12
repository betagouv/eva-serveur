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
        create(:evenement_demarrage, evaluation: evaluation, situation: situation),
        create(:evenement_reponse,
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
        create(:evenement_demarrage, evaluation: evaluation, situation: situation),
        create(:evenement_reponse,
               evaluation: evaluation,
               situation: situation,
               donnees: { question: question1.id, reponse: choix_question1.id })
      ]
      restitution = described_class.new(campagne, evenements)
      expect(restitution.choix_repondu(question1)).to eql(choix_question1)
    end

    it "ne retourne rien si la question n'a pas été répondu" do
      evenements = [
        create(:evenement_demarrage, evaluation: evaluation, situation: situation)
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
    let(:evenement_demarrage) do
      create(:evenement_demarrage, evaluation: evaluation, situation: situation)
    end

    let(:choix_question_1_bon) do
      create(:choix, intitule: 'bonne réponse', type_choix: 'bon',
                     question_id: question1.id)
    end
    let(:choix_question_1_mauvais) do
      create(:choix, intitule: 'mauvaise réponse', type_choix: 'mauvais',
                     question_id: question1.id)
    end
    let(:choix_question_1_abstention) do
      create(:choix, intitule: 'abstention réponse', type_choix: 'abstention',
                     question_id: question1.id)
    end

    def reponse_question_avec(question, choix)
      create(:evenement_reponse,
             evaluation: evaluation,
             situation: situation,
             donnees: { question: question.id, reponse: choix.id })
    end

    describe '#points_par_question' do
      it 'retourne 0.25 si absention' do
        restitution = described_class.new(
          campagne, [
            evenement_demarrage,
            reponse_question_avec(question1, choix_question_1_abstention)
          ]
        )
        questions_reponses = restitution.questions_et_reponses
        expect(restitution.points_par_question(questions_reponses)).to eq [0.25]
      end

      it 'retourne 1 si bonne réponse' do
        restitution = described_class.new(
          campagne, [
            evenement_demarrage,
            reponse_question_avec(question1, choix_question_1_bon)
          ]
        )
        questions_reponses = restitution.questions_et_reponses
        expect(restitution.points_par_question(questions_reponses)).to eq [1]
      end

      it 'retourne 0 si mauvaise réponse' do
        restitution = described_class.new(
          campagne, [
            evenement_demarrage,
            reponse_question_avec(question1, choix_question_1_mauvais)
          ]
        )
        questions_reponses = restitution.questions_et_reponses
        expect(restitution.points_par_question(questions_reponses)).to eq [0]
      end
    end

    context '#efficience' do
      let(:evenement_reponse_2) do
        create(:evenement_reponse,
               evaluation: evaluation,
               situation: situation,
               donnees: { question: question2.id, reponse: 5 })
      end

      let(:choix_question_2_bon) do
        create(:choix, intitule: 'bonne réponse', type_choix: 'bon',
                       question_id: question2.id)
      end

      it "ne calcule pas d'efficience lorsqu'il n'y a aucune réponses" do
        restitution = described_class.new(
          campagne, [
            evenement_demarrage
          ]
        )
        expect(restitution.efficience).to eq nil
      end

      it "ne calcule pas d'efficience lorsqu'il y a des réponses" do
        restitution = described_class.new(
          campagne, [
            evenement_demarrage,
            reponse_question_avec(question1, choix_question_1_mauvais),
            reponse_question_avec(question2, choix_question_2_bon)
          ]
        )
        expect(restitution.efficience).to eq nil
      end
    end
  end
end
