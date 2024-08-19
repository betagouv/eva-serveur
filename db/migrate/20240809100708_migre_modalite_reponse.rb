class MigreModaliteReponse < ActiveRecord::Migration[7.0]
  class ::Question < ApplicationRecord; end
  class ::Transcription < ApplicationRecord; end

  def change
    Question.where.not(modalite_reponse: nil).find_each do |question|
      Transcription.find_or_create_by(ecrit: question.modalite_reponse, question_id: question.id, categorie: :modalite_reponse)
    end
  end
end
