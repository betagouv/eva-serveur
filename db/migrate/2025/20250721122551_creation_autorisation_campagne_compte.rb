class CreationAutorisationCampagneCompte < ActiveRecord::Migration[7.2]
  def up
    create_table :campagne_compte_autorisations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :campagne_id, null: false, index: true
      t.uuid :compte_id, null: false, index: true
      t.datetime :deleted_at
      t.timestamps
   end
  end

  def down
    drop_table :campagne_compte_autorisations
  end
end
