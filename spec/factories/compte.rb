# frozen_string_literal: true

FactoryBot.define do
  factory :compte do
    email
    password { 'password' }
  end

  sequence :email do |n|
    "administrateur-#{n}@exemple.fr"
  end
end
