# frozen_string_literal: true

FactoryBot.define do
  factory :mise_en_action do
    evaluation
    effectuee { true }
  end
end
