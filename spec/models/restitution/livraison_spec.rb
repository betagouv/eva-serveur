# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Livraison do
  let(:evaluation) { create :evaluation, nom: 'Test' }
  let(:bon_choix_q1) { create :choix, :bon }
  let(:question1) do
    create :question_qcm, metacompetence: :numeratie, choix: [bon_choix_q1]
  end
  let(:question2) { create :question_qcm }
  let(:questionnaire) { create :questionnaire, questions: [question1, question2] }
  let!(:partie) { create :partie, situation: situation, evaluation: evaluation }
  let(:situation) do
    create :situation,
           libelle: 'Livraison',
           nom_technique: 'livraison',
           questionnaire: questionnaire
  end
  let(:campagne) { build :campagne }
  let(:restitution) { described_class.new(campagne, evenements) }
  let(:evenements) do
    [build(:evenement_demarrage)] + evenements_reponses
  end
  let(:evenements_reponses) { [] }

  describe '#questions_et_reponses' do
    context "retourne aucune question et réponse si aucune n'a été répondu" do
      it { expect(restitution.questions_et_reponses).to eq([]) }
    end

    context 'retourne les questions et les réponses du questionnaire' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
                donnees: { question: question1.id, reponse: bon_choix_q1.id })
        ]
      end
      it do
        expect(restitution.questions_et_reponses.size).to eq(1)
        expect(restitution.questions_et_reponses.first[:question]).to eql(question1)
        expect(restitution.questions_et_reponses.first[:reponse]).to eql(bon_choix_q1)
      end
    end

    context 'ignore les réponses aux questions qui ne sont pas une Question QCM' do
      let(:question_redaction_note) { create :question_redaction_note }
      let(:questionnaire) { create :questionnaire, questions: [question_redaction_note] }

      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
                donnees: { question: question_redaction_note.id, reponse: 'coucou' })
        ]
      end
      it { expect(restitution.questions_et_reponses).to eq([]) }
    end
  end

  describe '#reponses' do
    context 'retourne uniquement les réponses' do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_reponse)
        ]
      end
      it { expect(restitution.reponses.size).to eql(1) }
    end
  end

  describe '#efficience' do
    it 'retourne nil' do
      expect(restitution.efficience).to be_nil
    end
  end
end
