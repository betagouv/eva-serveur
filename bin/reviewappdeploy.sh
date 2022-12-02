#!/bin/bash

bundle exec rails db:migrate VERSION=20221125162847
bundle exec rake reviewapp:initdb
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
