#!/bin/bash

bundle exec rails db:migrate VERSION=20230329085445
bundle exec rake reviewapp:initdb
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
bundle exec rake questionnaire:complete_sociodemographique_autopositionnement
