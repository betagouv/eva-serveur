#!/bin/bash

bundle exec rails db:migrate VERSION=20221102151638
bundle exec rake reviewapp:initdb
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
