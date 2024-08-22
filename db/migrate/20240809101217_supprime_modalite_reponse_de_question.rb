class SupprimeModaliteReponseDeQuestion < ActiveRecord::Migration[7.0]
  def up
    remove_column :questions, :modalite_reponse, :string
  end

  def down
    add_column :questions, :modalite_reponse, :string
    Question.find_each do |question|
      if question.transcription_modalite_reponse.present?
        question.update(modalite_reponse: question.transcription_modalite_reponse&.ecrit)
      end
    end
  end
end
