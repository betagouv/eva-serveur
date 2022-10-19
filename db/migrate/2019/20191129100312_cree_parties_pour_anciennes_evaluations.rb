class CreePartiesPourAnciennesEvaluations < ActiveRecord::Migration[6.0]
  class Evenement < ApplicationRecord; end
  class Partie < ApplicationRecord; end

  def change
    Evenement.where(nom: 'demarrage').find_each do |evenement|
      Partie.where(evaluation_id: evenement.evaluation_id,
                     situation_id: evenement.situation_id,
                     session_id: evenement.session_id).first_or_create!
    end
  end
end
