class SupprimeEvenementsSansPartie < ActiveRecord::Migration[6.0]
  class Evenement < ApplicationRecord; end
  class Partie < ApplicationRecord; end

  def change
    Evenement.where.not(session_id: Partie.select(:session_id)).delete_all
  end
end
