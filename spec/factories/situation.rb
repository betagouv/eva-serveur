# frozen_string_literal: true

FactoryBot.define do
  sequence :nom_technique do |n|
    "nom_technique_#{n}"
  end

  factory :situation do
    nom_technique
  end
end
