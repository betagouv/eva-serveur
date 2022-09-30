#!/bin/bash

bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
