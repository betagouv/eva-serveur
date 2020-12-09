class CreateQuestionsFrequentes < ActiveRecord::Migration[6.0]
  def change
    create_table :questions_frequentes, id: :uuid do |t|
      t.string :question
      t.text :reponse

      t.timestamps
    end
  end
end
