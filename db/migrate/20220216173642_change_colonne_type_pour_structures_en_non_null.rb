class ChangeColonneTypePourStructuresEnNonNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :structures, :type, true

  end
end
