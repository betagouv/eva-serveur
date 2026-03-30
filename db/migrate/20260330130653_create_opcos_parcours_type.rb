class CreateOpcosParcoursType < ActiveRecord::Migration[7.2]
  def change
    create_table :opcos_parcours_type, id: :uuid do |t|
      t.references :opco, null: false, type: :uuid, foreign_key: true
      t.references :parcours_type, null: false, type: :uuid, foreign_key: true
      t.timestamps
    end
  end
end
