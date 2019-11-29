class EmpecheMetriquesDEtreVideDansParties < ActiveRecord::Migration[6.0]
  def change
    Partie.where(metriques: nil).update_all metriques: {}
    change_column_null :parties, :metriques, false
  end
end
