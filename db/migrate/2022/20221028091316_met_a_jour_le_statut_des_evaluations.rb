class MetAJourLeStatutDesEvaluations < ActiveRecord::Migration[7.0]
  class Evaluation < ApplicationRecord
    enum :statut, %i[a_suivre suivi_en_cours suivi_effectue]
  end

  def up
    Evaluation.where('created_at >= ?', 1.month.ago).update_all(statut: :a_suivre)
    Evaluation.where('created_at BETWEEN ? AND ?', 6.month.ago, 1.month.ago).update_all(statut: :suivi_en_cours)
    Evaluation.where('created_at < ?', 6.month.ago).update_all(statut: :suivi_effectue)
  end

  def down
    Evaluation.update_all(statut: :a_suivre)
  end
end
