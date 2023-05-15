class ChangeColonneCollationAncestryPourStructures < ActiveRecord::Migration[7.0]
  class Structure < ApplicationRecord
    has_ancestry
  end
  def change
    model = Structure
    # set all child nodes
    model.where.not(model.arel_table[model.ancestry_column].eq(nil)).update_all("#{model.ancestry_column} = CONCAT('#{model.ancestry_delimiter}', #{model.ancestry_column}, '#{model.ancestry_delimiter}')")
    # set all root nodes
    model.where(model.arel_table[model.ancestry_column].eq(nil)).update_all("#{model.ancestry_column} = '#{model.ancestry_root}'")

    change_column :structures, :ancestry, :string, collation: 'C', null: false
  end
end
