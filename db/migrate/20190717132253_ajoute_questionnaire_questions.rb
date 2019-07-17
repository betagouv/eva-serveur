class AjouteQuestionnaireQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questionnaires_questions, id: false do |t|
      t.belongs_to :questionnaire, index: true
      t.belongs_to :question, index: true
    end
  end
end
