#!/bin/bash

bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
bundle exec rails db < db/evaluations_tests.sql
