class CreeAffectationsComptesExternes < ActiveRecord::Migration[7.2]
  def change
    create_table :affectations_comptes_externes, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :evaluation_id, null: false, index: true
      t.uuid :compte_id, null: false, index: true
      t.timestamps
    end
  end
end
