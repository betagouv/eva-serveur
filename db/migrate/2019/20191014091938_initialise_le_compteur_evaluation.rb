class InitialiseLeCompteurEvaluation < ActiveRecord::Migration[6.0]
  def change
    Campagne.find_each do |campagne|
      Campagne.reset_counters(campagne.id, :evaluations)
    end
  end
end
