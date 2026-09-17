#!/bin/bash -x

bundle exec rake reviewapp:initdb
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
