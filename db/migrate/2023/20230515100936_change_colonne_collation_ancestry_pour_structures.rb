class ChangeColonneCollationAncestryPourStructures < ActiveRecord::Migration[7.0]
  class Structure < ApplicationRecord
    has_ancestry
  end
  def up
    model = Structure
    # set all child nodes
    model.where.not(model.arel_table[model.ancestry_column].eq(nil)).update_all("#{model.ancestry_column} = CONCAT('#{model.ancestry_delimiter}', #{model.ancestry_column}, '#{model.ancestry_delimiter}')")
    # set all root nodes
    model.where(model.arel_table[model.ancestry_column].eq(nil)).update_all("#{model.ancestry_column} = '#{model.ancestry_root}'")

    change_column :structures, :ancestry, :string, collation: 'C', null: false
  end

  def down
    # Cette fonction n'a jamais été implémenté mais ça ne se voyait pas car
    # nous utilisions la méthode "change" au lieu de "up" et "down".
    #
    # This migration used change_column, which is not automatically reversible.
    # To make the migration reversible you can either:
    # 1. Define #up and #down methods in place of the #change method.
    # 2. Use the #reversible method to define reversible behavior.
  end
end
