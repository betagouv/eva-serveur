# frozen_string_literal: true

FactoryBot.define do
  factory :evenement do
    nom { 'ouvertureContenant' }
    donnees { JSON.parse(File.read("#{Rails.root}/spec/support/evenement/donnees.json")) }
    situation { 'inventaire' }
    session_id { '07319b2485be9ac4850664cd47cede38' }
    date { DateTime.now }
  end
end
