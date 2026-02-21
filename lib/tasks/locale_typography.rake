# frozen_string_literal: true

namespace :locale_typography do
  desc "Vérifie les espaces insécables dans les traductions (avant : ! ?, après « et avant »)"
  task check: :environment do
    Linters::LocaleTypography.run
  end
end

task locale_typography: "locale_typography:check"
