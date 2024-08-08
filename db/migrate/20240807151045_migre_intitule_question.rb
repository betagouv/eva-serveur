class MigreIntituleQuestion < ActiveRecord::Migration[7.0]
  def change
    Question.find_each do |question|
      if question.intitule.present?
        Transcription.find_or_create_by(ecrit: question.intitule, question_id: question.id)
      end
    end
  end
end
