class AjouteUsagePourStructureLocale < ActiveRecord::Migration[7.2]
  USAGE = %w["Eva: bénéficiaires" "Eva: entreprises"].freeze

  def change
    add_column :structures, :usage, :string, default: "Eva: bénéficiaires"
    add_index :structures, :usage
  end
end
