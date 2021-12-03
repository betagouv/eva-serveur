#!/bin/bash

DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:drop db:create db:schema:load
psql eva_development < $DRIVE/PRODUIT/Documentation_technique/db_preprod.pgsql
bundle exec rake db:seed
