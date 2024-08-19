class MigreIntituleQuestion < ActiveRecord::Migration[7.0]
  class ::Question < ApplicationRecord; end
  class ::Transcription < ApplicationRecord; end

  def change
    Question.where.not(intitule: nil).find_each do |question|
      Transcription.find_or_create_by(ecrit: question.intitule, question_id: question.id)
    end
  end
end
