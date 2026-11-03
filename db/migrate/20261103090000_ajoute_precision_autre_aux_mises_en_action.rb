class AjoutePrecisionAutreAuxMisesEnAction < ActiveRecord::Migration[8.0]
  def change
    add_column :mises_en_action, :precision_autre, :text
  end
end
