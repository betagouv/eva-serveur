class AjouteDeletedAtManquant < ActiveRecord::Migration[7.0]
  def change
    add_column :parcours_type, :deleted_at, :datetime
    add_index :parcours_type, :deleted_at

    add_column :situations, :deleted_at, :datetime
    add_index :situations, :deleted_at

    add_column :situations_configurations, :deleted_at, :datetime
    add_index :situations_configurations, :deleted_at

    add_column :beneficiaires, :deleted_at, :datetime
    add_index :beneficiaires, :deleted_at

    add_column :conditions_passations, :deleted_at, :datetime
    add_index :conditions_passations, :deleted_at

    add_column :donnees_sociodemographiques, :deleted_at, :datetime
    add_index :donnees_sociodemographiques, :deleted_at

    add_column :parties, :deleted_at, :datetime
    add_index :parties, :deleted_at

    add_column :evenements, :deleted_at, :datetime
    add_index :evenements, :deleted_at

    add_column :questionnaires, :deleted_at, :datetime
    add_index :questionnaires, :deleted_at

    add_column :questionnaires_questions, :deleted_at, :datetime
    add_index :questionnaires_questions, :deleted_at

    add_column :questions, :deleted_at, :datetime
    add_index :questions, :deleted_at
  end
end
