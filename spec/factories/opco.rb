FactoryBot.define do
  factory :opco do
    sequence(:nom) { |n| "OPCO #{n}" }
    financeur { true }

    trait :constructys do
      nom { "Constructys" }
    end

    trait :opco_sante do
      nom { "OPCO Santé" }
    end

    trait :opco_non_financeur do
      nom { "OPCO Non Financeur" }
      financeur { false }
    end

    trait :opco_mobilites do
      nom { "OPCO Mobilités" }
    end
  end
end
