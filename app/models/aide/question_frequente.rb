# frozen_string_literal: true

module Aide
  class QuestionFrequente < ApplicationRecord
    validates :question, :reponse, presence: true

    def display_name
      question
    end
  end
end
