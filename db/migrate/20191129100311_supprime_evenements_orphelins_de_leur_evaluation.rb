class SupprimeEvenementsOrphelinsDeLeurEvaluation < ActiveRecord::Migration[6.0]
  def change
    Evenement.where(evaluation_id: nil).delete_all
  end
end
