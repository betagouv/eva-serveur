class CreateChoix < ActiveRecord::Migration[5.2]
  def change
    create_table :choix do |t|
      t.string :intitule
      t.references :question, foreign_key: true
      t.integer :type_choix

      t.timestamps
    end
  end
end
