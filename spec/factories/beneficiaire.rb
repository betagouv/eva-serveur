FactoryBot.define do
  factory :beneficiaire do
    sequence(:nom) { |n| "Roger #{n}" }
  end
end
