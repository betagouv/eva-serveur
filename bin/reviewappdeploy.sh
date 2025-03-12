#!/bin/bash -x

bundle exec rails db:migrate VERSION=20210305110556
bundle exec rails db:migrate VERSION=20230406135310
bundle exec rake reviewapp:ignore_migrations[20230419084251,20230407134617,20240624120736]
bundle exec rails db:migrate VERSION=20240809100708
bundle exec rake reviewapp:initdb
bundle exec rails db:migrate VERSION=20241206052500
bundle exec rake reviewapp:ignore_migrations[20241206064741,20250103165108,20250103172005]
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rake reviewapp:seed
