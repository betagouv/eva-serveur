#!/bin/bash

bundle exec rails db:migrate VERSION=20230329085445
bundle exec rake reviewapp:initdb
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
bundle exec rake migration:bienvenue2023
bundle exec rake evenements:update_questions_reponses
bundle exec rake migration_donnees:initialise_categorie_questions
