require 'rails_helper'

describe QuestionnaireQuestion do
  context 'validation unicité' do
    subject { described_class.new(question: question) }

    let(:question) { create(:question) }

    it do
      expect(subject)
        .to validate_uniqueness_of(:question_id).scoped_to(:questionnaire_id).case_insensitive
    end
  end
end
