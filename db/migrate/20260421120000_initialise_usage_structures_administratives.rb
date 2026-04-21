class InitialiseUsageStructuresAdministratives < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL.squish
      UPDATE structures
      SET usage = 'Eva: bénéficiaires'
      WHERE type = 'StructureAdministrative'
        AND (usage IS NULL OR usage = '')
    SQL
  end

  def down
    # Pas de rollback de données pour éviter d'effacer une valeur potentiellement valide.
  end
end
