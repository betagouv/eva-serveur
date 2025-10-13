FactoryBot.define do
  factory :opco do
    sequence(:nom) { |n| "OPCO #{n}" }
    financeur { false }

    trait :constructys do
      nom { "Constructys" }
    end

    trait :opco_sante do
      nom { "OPCO Santé" }
    end
  end
end
