class SupprimeEvenementsOrphelinsDeLeurEvaluation < ActiveRecord::Migration[6.0]
  class Evenement < ApplicationRecord; end

  def change
    Evenement.where(evaluation_id: nil).delete_all
  end
end
