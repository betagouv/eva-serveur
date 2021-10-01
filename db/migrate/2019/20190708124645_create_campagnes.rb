class CreateCampagnes < ActiveRecord::Migration[5.2]
  def change
    create_table :campagnes do |t|
      t.string :libelle
      t.string :code

      t.timestamps
    end
  end
end
