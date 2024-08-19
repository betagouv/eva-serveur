#!/bin/bash

bundle exec rails db:migrate VERSION=20230406135310
bundle exec rake reviewapp:ignore_migrations[20230419084251,20230407134617]
bundle exec rails db:migrate VERSION=20240809100708
bundle exec rake reviewapp:initdb
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
