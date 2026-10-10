require Rails.root.join("lib/rake_logger")

namespace :reviewapp do
  # APP est le nom de l'application, injecté par Scalingo dans chaque conteneur
  def interdit_en_production(tache)
    abort "#{tache.name} ne doit jamais être exécuté en production" if ENV["APP"] == "eva-serveur"
  end

  desc "Ignore migrations"
  task ignore_migrations: :environment do |tache, args|
    interdit_en_production(tache)

    logger = RakeLogger.logger
    ActiveRecord::Base.transaction do
      args.extras.each do |migration|
        logger.info("ignore la migration #{migration}")
        ActiveRecord::Base.connection
                          .execute("INSERT INTO public.schema_migrations VALUES ('#{migration}');")
      end
    end
  end

  desc "Vide entièrement la base de préproduction"
  task videdb: :environment do |tache|
    if ENV["APP"] != "eva-serveur-preprod"
      abort "#{tache.name} ne doit être exécuté que sur eva-serveur-preprod"
    end

    connexion = ActiveRecord::Base.connection
    tables = connexion.tables.map { |table| connexion.quote_table_name(table) }
    connexion.execute("DROP TABLE #{tables.join(', ')} CASCADE") if tables.any?
  end

  desc "init db"
  task initdb: :environment do |tache|
    interdit_en_production(tache)

    contenu = File.read("db/evaluations_tests.sql")
    requettes = contenu.split(/;$/)
    requettes.pop ## retire la dernière requette qui est vide
    ActiveRecord::Base.transaction do
      requettes.each do |requette|
        ActiveRecord::Base.connection.execute(requette)
      end
    end
  end

  desc "initialise les données pour les applications de revues"
  task seed: :environment do |tache|
    interdit_en_production(tache)

    mot_de_passe = ENV.fetch("MOT_DE_PASSE_COMPTES_PREPROD")
    mot_de_passe_chiffre = Devise::Encryptor.digest(Compte, mot_de_passe)
    Compte.find_each do |compte|
      compte.encrypted_password = mot_de_passe_chiffre
      compte.save!(validate: false)
    end
  end
end
