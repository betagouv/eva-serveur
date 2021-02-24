# frozen_string_literal: true

FactoryBot.define do
  factory :compte, aliases: [:compte_admin] do
    email
    password { 'password' }
    role { 'administrateur' }

    factory :compte_organisation do
      role { 'organisation' }
    end
    structure
  end

  sequence :email do |n|
    "administrateur-#{n}@exemple.fr"
  end
end
