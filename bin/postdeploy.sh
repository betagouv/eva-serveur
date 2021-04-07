#!/bin/bash

if [[ -z "$RAILS_ENV" || "$RAILS_ENV" = "development" ]] ; then
  cat
else
  bundle exec rake db:migrate
fi
