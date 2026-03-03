# frozen_string_literal: true

class CreateInvitations < ActiveRecord::Migration[7.2]
  def change
    create_table :invitations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :token, null: false, index: { unique: true }
      t.references :structure, type: :uuid, null: false, foreign_key: true
      t.string :email_destinataire
      t.references :invitant, type: :uuid, null: false, foreign_key: { to_table: :comptes }
      t.string :statut, default: "en_cours", null: false
      t.references :compte, type: :uuid, null: true, foreign_key: true
      t.text :message_personnalise

      t.timestamps
    end
  end
end
