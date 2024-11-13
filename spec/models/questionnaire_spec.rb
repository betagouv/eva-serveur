# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  it { is_expected.to have_many(:questionnaires_questions).dependent(:destroy) }

  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of :nom_technique }

  describe '#livraison_sans_redaction?' do
    context 'quand le questionnaire est livraison sans rédaction' do
      let(:questionnaire) do
        described_class.new nom_technique: Questionnaire::LIVRAISON_SANS_REDACTION
      end

      it { expect(questionnaire.livraison_sans_redaction?).to be(true) }
    end

    context "quand le questionnaire n'est pas livraison sans rédaction" do
      let(:questionnaire) do
        described_class.new nom_technique: Questionnaire::LIVRAISON_AVEC_REDACTION
      end

      it { expect(questionnaire.livraison_sans_redaction?).to be(false) }
    end
  end

  describe '#questions_par_type' do
    let(:questionnaire) { create :questionnaire }
    let(:question_clic_dans_image) { create :question_clic_dans_image }
    let(:question_qcm) { create :question_qcm }

    before do
      create :questionnaire_question, questionnaire_id: questionnaire.id,
                                      question_id: question_clic_dans_image.id
      create :questionnaire_question, questionnaire_id: questionnaire.id,
                                      question_id: question_qcm.id
    end

    it do
      expect(questionnaire.questions_par_type).to eq(
        'QuestionClicDansImage' => [question_clic_dans_image],
        'QuestionQcm' => [question_qcm]
      )
    end
  end
end
