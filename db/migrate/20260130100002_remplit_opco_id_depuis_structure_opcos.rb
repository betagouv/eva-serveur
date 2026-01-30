# frozen_string_literal: true

class RemplitOpcoIdDepuisStructureOpcos < ActiveRecord::Migration[7.2]
  def up
    return unless table_exists?(:structure_opcos)

    execute(<<-SQL.squish)
      UPDATE structures s
      SET opco_id = sub.opco_id
      FROM (
        SELECT DISTINCT ON (structure_id) structure_id, opco_id
        FROM structure_opcos so
        INNER JOIN opcos o ON o.id = so.opco_id
        ORDER BY structure_id, o.financeur DESC NULLS LAST, so.created_at ASC
      ) sub
      WHERE s.id = sub.structure_id
      AND s.opco_id IS NULL
    SQL
  end

  def down
    # Pas de rollback : on ne recrée pas structure_opcos depuis opco_id
  end
end
