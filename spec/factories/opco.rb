FactoryBot.define do
  factory :opco do
    sequence(:nom) { |n| "OPCO #{n}" }
    financeur { true }

    after(:build) do |opco|
      if opco.opco_parcours_types.empty?
        opco.opco_parcours_types.build(
          parcours_type: build(:parcours_type)
        )
      end
    end

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
