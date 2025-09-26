class AjouteSynthesePourParties < ActiveRecord::Migration[7.2]
  def change
    add_column :parties, :synthese, :jsonb, default: {}, null: false
    add_column :parties, :competences, :jsonb, default: {}, null: false
    add_column :parties, :competences_de_base, :jsonb, default: {}, null: false
  end
end
