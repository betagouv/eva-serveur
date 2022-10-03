#!/bin/bash

bundle exec rails db:migrate
bundle exec rake reviewapp:initdb
bundle exec rails db:seed
bundle exec rake reviewapp:seed
