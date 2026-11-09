desc "Lance rubocop -A, locale_typography, lint:css, test:js et rspec " \
     "(en sequence, stop au premier echec)"
task validation: :environment do
  sh "bundle exec rubocop -A"
  Rake::Task["locale_typography"].invoke
  sh "npm run lint:css"
  sh "npm run test:js"
  sh "bundle exec rspec"
end
