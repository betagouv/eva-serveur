#!/bin/bash -x

# Depuis Rails 8, ActiveRecord::Tasks::DatabaseTasks#migrate_all charge
# automatiquement db/schema.rb avant de migrer si la base est vierge (table
# schema_migrations absente). Sur une review app la base est fournie vide :
# ça amène le schéma direct à HEAD, puis comme la cible du VERSION= ci-dessous
# est antérieure, Rails redescend (down) toutes les migrations jusque-là et
# tombe sur une migration irréversible (drop_table sans bloc de colonnes).
# On crée la table schema_migrations vide en amont pour que Rails considère
# la base comme déjà initialisée et rejoue les migrations dans l'ordre, comme
# avant Rails 8.
bundle exec rails runner 'ActiveRecord::Base.connection_pool.schema_migration.create_table unless ActiveRecord::Base.connection_pool.schema_migration.table_exists?'

bundle exec rails db:migrate VERSION=20210305110556
bundle exec rails db:migrate VERSION=20230406135310
bundle exec rake reviewapp:ignore_migrations[20230419084251,20230407134617,20240624120736]
bundle exec rails db:migrate VERSION=20240809100708
bundle exec rake reviewapp:initdb
bundle exec rails db:migrate VERSION=20241206052500
bundle exec rake reviewapp:ignore_migrations[20241206064741,20250103165108,20250103172005]
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
