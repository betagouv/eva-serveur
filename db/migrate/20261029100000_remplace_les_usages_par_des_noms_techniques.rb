class RemplaceLesUsagesParDesNomsTechniques < ActiveRecord::Migration[8.0]
  # [ancienne valeur, nom technique]
  USAGES = [
    [ "Eva: bénéficiaires", "eva" ],
    [ "EVAPRO", "evapro" ],
    [ "Eva: entreprises", "evapro" ]
  ].freeze

  def up
    change_column_default :structures, :usage, from: "Eva: bénéficiaires", to: "eva"
    USAGES.each do |ancienne_valeur, nom_technique|
      execute_update(ancienne_valeur, nom_technique)
    end
  end

  def down
    change_column_default :structures, :usage, from: "eva", to: "Eva: bénéficiaires"
    USAGES.first(2).each do |ancienne_valeur, nom_technique|
      execute_update(nom_technique, ancienne_valeur)
    end
  end

  private

  def execute_update(de, vers)
    %w[structures comptes].each do |table|
      execute <<~SQL
        UPDATE #{table} SET usage = #{connection.quote(vers)}
        WHERE usage = #{connection.quote(de)}
      SQL
    end
  end
end
