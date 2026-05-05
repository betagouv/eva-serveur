class OptimizeEvenementsJsonbQueries < ActiveRecord::Migration[7.2]
  def up
    # Index pour la question dans les données JSONB
    execute "CREATE INDEX index_evenements_on_donnees_question ON evenements ((donnees ->> 'question'))"

    # Index composé pour nom + question (plus efficace pour cette requête)
    execute "CREATE INDEX index_evenements_on_nom_and_donnees_question ON evenements (nom, (donnees ->> 'question'))"
  end

  def down
    execute "DROP INDEX IF EXISTS index_evenements_on_donnees_question"
    execute "DROP INDEX IF EXISTS index_evenements_on_nom_and_donnees_question"
  end
end