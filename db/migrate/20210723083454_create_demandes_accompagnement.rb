class CreateDemandesAccompagnement < ActiveRecord::Migration[6.1]
  def change
    create_table :demandes_accompagnement, id: :uuid do |t|
      t.string :conseiller_nom
      t.string :conseiller_prenom
      t.string :conseiller_email
      t.string :conseiller_telephone
      t.belongs_to :compte, null: false, foreign_key: true, type: :uuid
      t.text :probleme_rencontre
      t.belongs_to :evaluation, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
