# frozen_string_literal: true

class MigreStructureOpcosVersStructuresOpcoId < ActiveRecord::Migration[7.2]
  def up
    return unless table_exists?(:structure_opcos)

    # Pour chaque structure ayant des structure_opcos, on remplit structures.opco_id avec :
    # l'OPCO financeur s'il y en a un, sinon le premier (par opco_id pour déterminisme)
    execute <<-SQL.squish
      UPDATE structures s
      SET opco_id = (
        SELECT so.opco_id
        FROM structure_opcos so
        INNER JOIN opcos o ON o.id = so.opco_id
        WHERE so.structure_id = s.id
        ORDER BY o.financeur DESC NULLS LAST, so.opco_id ASC
        LIMIT 1
      )
      WHERE EXISTS (
        SELECT 1 FROM structure_opcos so WHERE so.structure_id = s.id
      )
    SQL
  end

  def down
    # Pas de rollback des données : structure_opcos sera recréé par une migration ultérieure si besoin
  end
end
