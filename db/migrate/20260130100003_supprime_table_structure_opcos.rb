# frozen_string_literal: true

class SupprimeTableStructureOpcos < ActiveRecord::Migration[7.2]
  def change
    drop_table :structure_opcos, if_exists: true do |t|
      t.uuid :structure_id, null: false
      t.uuid :opco_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
