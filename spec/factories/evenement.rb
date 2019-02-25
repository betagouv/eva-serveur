# frozen_string_literal: true

FactoryBot.define do
  factory :evenement do
    type_evenement { 'ouvertureContenant' }
    description { JSON.parse(File.read("#{Rails.root}/spec/support/evenement/description.json")) }
    date { DateTime.now }
  end
end
