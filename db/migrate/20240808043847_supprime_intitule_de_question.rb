class SupprimeIntituleDeQuestion < ActiveRecord::Migration[7.0]
  def up
    remove_column :questions, :intitule, :string
  end

  def down
    add_column :questions, :intitule, :string
    Question.find_each do |question|
      if question.transcription_ecrite_pour(:intitule).present?
        question.update(intitule: question.transcription_ecrite_pour(:intitule))
      end
    end
  end
end
