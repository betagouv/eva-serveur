class CreateEvenements < ActiveRecord::Migration[5.2]
  def change
    create_table :evenements do |t|
      t.string :type_evenement
      t.text :description
      t.datetime :date

      t.timestamps
    end
  end
end
