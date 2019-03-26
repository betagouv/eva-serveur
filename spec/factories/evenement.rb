# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory :evenement do
    nom { 'ouvertureContenant' }
    donnees { JSON.parse(File.read("#{Rails.root}/spec/support/evenement/donnees.json")) }
    situation { 'inventaire' }
    session_id { '07319b2485be9ac4850664cd47cede38' }
    date { DateTime.now }

    factory :evenement_demarrage do
      nom { 'demarrage' }
      donnees { {} }
    end

    factory :evenement_saisie_inventaire do
      nom { 'saisieInventaire' }
      donnees { {} }

      factory :evenement_saisie_inventaire_ok do
        donnees do
          { reussite: true }
        end
      end

      factory :evenement_saisie_inventaire_echec do
        donnees do
          { reussite: false }
        end
      end
    end

    factory :evenement_ouverture_contenant do
      nom { 'ouvertureContenant' }
      donnees { { contenant: 1 } }
    end

    factory :evenement_stop do
      nom { 'stop' }
      donnees { {} }
    end
  end
end
# rubocop:enable Metrics/BlockLength
