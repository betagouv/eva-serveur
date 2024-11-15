class CreateConditionsPassation < ActiveRecord::Migration[7.0]
  def change
    create_table :conditions_passation, id: :uuid do |t|
      t.string :materiel_utilise
      t.string :modele_materiel
      t.string :nom_navigateur
      t.string :version_navigateur
      t.string :resolution_ecran
      t.references :evaluation, index: true, foreign_key: { on_delete: :cascade }, type: :uuid

      t.timestamps
    end
  end
end
