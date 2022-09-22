class CreateParcoursTypeCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :parcours_type_categories, id: :uuid do |t|
      t.string :nom

      t.timestamps
    end
  end
end
