#!/bin/bash

bundle exec rails db:migrate VERSION=20230329085445
bundle exec rake reviewapp:initdb
bundle exec rails db:migrate VERSION=20230407150248
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
