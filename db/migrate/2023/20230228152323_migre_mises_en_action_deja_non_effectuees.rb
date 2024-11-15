class MigreMisesEnActionDejaNonEffectuees < ActiveRecord::Migration[7.0]
  def change
    MiseEnAction.where(effectuee: false).where(difficulte: nil).update_all(difficulte: 'indetermine')
  end
end
