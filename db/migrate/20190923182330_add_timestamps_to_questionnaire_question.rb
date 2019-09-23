class AddTimestampsToQuestionnaireQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :questionnaires_questions, :created_at, :datetime
    add_column :questionnaires_questions, :updated_at, :datetime
  end
end
