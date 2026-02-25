# frozen_string_literal: true

desc "Lance rubocop -A, locale_typography, lint:css et rspec (en sequence, stop au premier echec)"
task validation: :environment do
  sh "bundle exec rubocop -A"
  Rake::Task["locale_typography"].invoke
  sh "npm run lint:css"
  sh "bundle exec rspec"
end
