# frozen_string_literal: true

namespace :locale_opco do
  desc "Vérifie l'absence du mot 'OPCO' dans les traductions \
    (doit être remplacé par 'Opérateur de Compétences')"
  task check: :environment do
    Linters::LocaleOpco.run
  end
end

task locale_opco: "locale_opco:check"
