class CreateQuestionnaires < ActiveRecord::Migration[5.2]
  def change
    create_table :questionnaires do |t|
      t.string :libelle
      t.jsonb :questions

      t.timestamps
    end
  end
end
