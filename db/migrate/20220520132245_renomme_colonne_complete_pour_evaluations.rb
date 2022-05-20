class RenommeColonneCompletePourEvaluations < ActiveRecord::Migration[6.1]
  def change
    rename_column :evaluations, :complete, :completude
  end
end
