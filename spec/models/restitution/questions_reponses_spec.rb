# frozen_string_literal: true

require 'rails_helper'

describe Restitution::QuestionsReponses do
  let(:restitution) { described_class.new(evenements, questionnaire) }
  let(:bon_choix_q1) { create :choix, :bon }
  let(:bon_choix_qjauge) { create :choix, :bon }
  let(:question1) do
    create :question_qcm, choix: [bon_choix_q1]
  end
  let(:question_jauge) do
    create :question_qcm, choix: [bon_choix_qjauge], type_qcm: :jauge
  end
  let(:questionnaire) { create :questionnaire, questions: [question1, question_jauge] }

  describe '#questions_et_reponses' do
    context "retourne aucune question et réponse si aucune n'a été répondu" do
      let(:evenements) { [build(:evenement_demarrage)] }

      it { expect(restitution.questions_et_reponses).to eq([]) }
    end

    context 'retourne les questions et les réponses du questionnaire' do
      let(:evenements) do
        [
          build(:evenement_reponse,
                donnees: { question: question1.id, reponse: bon_choix_q1.id })
        ]
      end

      it do
        expect(restitution.questions_et_reponses.size).to eq(1)
        expect(restitution.questions_et_reponses.first[0]).to eql(question1)
        expect(restitution.questions_et_reponses.first[1]).to eql(bon_choix_q1)
      end
    end

    context 'renvoie le texte de réponse pour les questions qui ne sont pas des Questions QCM' do
      let(:question_redaction_note) { create :question_saisie }
      let(:questionnaire) { create :questionnaire, questions: [question_redaction_note] }

      let(:evenements) do
        [
          build(:evenement_reponse,
                donnees: { question: question_redaction_note.id, reponse: 'coucou' })
        ]
      end

      it { expect(restitution.questions_et_reponses.first[1]).to eql('coucou') }
    end

    context 'retourne seulement les questions de type jauge' do
      let(:evenements) do
        [
          build(:evenement_reponse,
                donnees: { question: question_jauge.id, reponse: bon_choix_qjauge.id }),

          build(:evenement_reponse,
                donnees: { question: question1.id, reponse: bon_choix_q1.id })
        ]
      end

      it do
        questions = restitution.questions_et_reponses(:jauge)
        expect(questions.size).to eq(1)
        expect(questions.first[0]).to eql(question_jauge)
      end
    end
  end

  describe 'questions_redaction' do
    context 'renvoie les questions de saisie et leur réponse' do
      let(:question_redaction_note) { create :question_saisie }
      let(:questionnaire) do
        create :questionnaire, questions: [question_redaction_note, question1]
      end

      let(:evenements) do
        [
          build(:evenement_reponse,
                donnees: { question: question_redaction_note.id, reponse: 'ton b' }),
          build(:evenement_reponse,
                donnees: { question: question1.id, reponse: bon_choix_q1.id })
        ]
      end

      it { expect(restitution.questions_redaction.count).to be(1) }
      it { expect(restitution.questions_redaction.first[1]).to eql('ton b') }
    end
  end

  describe '#choix_reponse' do
    context 'retourne le choix répondu' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_reponse,
                donnees: { question: question1.id, reponse: bon_choix_q1.id })
        ]
      end

      it { expect(restitution.choix_repondu(question1)).to eql(bon_choix_q1) }
    end

    context "ne retourne rien si la question n'a pas été répondu" do
      let(:evenements) { [] }

      it { expect(restitution.choix_repondu(question1)).to be_nil }
    end
  end

  describe '#reponses' do
    context 'retourne toutes les réponses' do
      let(:evenements) do
        [
          build(:evenement_reponse),
          build(:evenement_reponse)
        ]
      end

      it { expect(restitution.reponses.size).to be(2) }
    end

    context 'retourne seulement les événements réponses' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_reponse)
        ]
      end

      it { expect(restitution.reponses.size).to be(1) }
    end
  end
end
