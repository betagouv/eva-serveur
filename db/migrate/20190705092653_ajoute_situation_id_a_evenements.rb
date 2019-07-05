class AjouteSituationIdAEvenements < ActiveRecord::Migration[5.2]
  def change
    add_reference :evenements, :situation, foreign_key: true
  end
end
