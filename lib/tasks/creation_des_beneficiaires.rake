# frozen_string_literal: true

namespace :beneficiaire do
  desc "Mets à jour le nom du bénéficiaire associé à l'évaluation"
  task mise_a_jour_du_nom: :environment do
    Evaluation.all.find_each do |evaluation|
      evaluation.beneficiaire_create_or_update_nom!
    end
  end
end
