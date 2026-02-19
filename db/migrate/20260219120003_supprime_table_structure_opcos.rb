# frozen_string_literal: true

class SupprimeTableStructureOpcos < ActiveRecord::Migration[7.2]
  def change
    drop_table :structure_opcos, if_exists: true
  end
end
