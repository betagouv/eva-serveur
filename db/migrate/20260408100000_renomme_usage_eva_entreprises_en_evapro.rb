# frozen_string_literal: true

class RenommeUsageEvaEntreprisesEnEvapro < ActiveRecord::Migration[7.2]
  ANCIEN_USAGE = "Eva: entreprises"
  NOUVEL_USAGE = "EVAPRO"

  def up
    execute <<~SQL.squish
      UPDATE structures
      SET usage = '#{NOUVEL_USAGE}'
      WHERE usage = '#{ANCIEN_USAGE}'
    SQL

    execute <<~SQL.squish
      UPDATE comptes
      SET usage = '#{NOUVEL_USAGE}'
      WHERE usage = '#{ANCIEN_USAGE}'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE structures
      SET usage = '#{ANCIEN_USAGE}'
      WHERE usage = '#{NOUVEL_USAGE}'
    SQL

    execute <<~SQL.squish
      UPDATE comptes
      SET usage = '#{ANCIEN_USAGE}'
      WHERE usage = '#{NOUVEL_USAGE}'
    SQL
  end
end
