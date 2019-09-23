# frozen_string_literal: true

require 'rails_helper'

describe QuestionnaireQuestion do
  context 'validation unicité' do
    let(:question) { create(:question) }

    subject { described_class.new(question: question) }

    it { should validate_uniqueness_of(:question_id).scoped_to(:questionnaire_id).case_insensitive }
  end
end
