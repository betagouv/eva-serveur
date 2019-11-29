class SupprimeEvenementsSansPartie < ActiveRecord::Migration[6.0]
  def change
    Evenement.where.not(session_id: Partie.select(:session_id)).delete_all
  end
end
