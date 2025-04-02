# frozen_string_literal: true

require 'rails_helper'

describe QuestionData, type: :model do
  describe 'Chargement de la premiere question' do
    before { stub_static_record_data_loading(yml_data) }

    let(:yml_data) do
      [
        { 'nom_technique' => 'question_1', 'score' => 1, 'metacompetence' => 'comprehension' },
        { 'nom_technique' => 'question_2', 'score' => 2, 'metacompetence' => 'production' }
      ]
    end

    it 'charge la premiere question et verifie ses attributs' do
      questions = described_class.all
      premiere_question = questions.first

      expect(premiere_question).to be_a(described_class)
      expect(premiere_question.nom_technique).to eq('question_1')
      expect(premiere_question.score).to eq(1)
      expect(premiere_question.metacompetence).to eq('comprehension')
    end
  end
end
