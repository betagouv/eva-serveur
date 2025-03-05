class SupprimeMetacompetencePourQuestion < ActiveRecord::Migration[7.2]
  class Question < ApplicationRecord; end

  def up
    remove_column :questions, :metacompetence, :integer
    rename_column :questions, :new_metacompetence, :metacompetence
  end

  def down
    rename_column :questions, :metacompetence, :new_metacompetence
    add_column :questions, :metacompetence, :integer
  end
end
