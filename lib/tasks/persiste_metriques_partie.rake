# frozen_string_literal: true

desc 'Persiste les métriques pour toutes les parties'
task persiste_metriques: :environment do
  Partie.find_each do |partie|
    partie.persiste_restitution if partie.restitution.termine?
  end
end
