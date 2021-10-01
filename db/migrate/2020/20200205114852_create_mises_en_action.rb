class CreateMisesEnAction < ActiveRecord::Migration[6.0]
  def change
    create_table :mises_en_action, id: :uuid do |t|
      t.boolean :elements_decouverts
      t.text :precision_elements_decouverts
      t.boolean :recommandations_candidat
      t.integer :type_recommandation
      t.text :precision_recommandation
      t.text :elements_facilitation_recommandation

      t.timestamps
    end
  end
end
