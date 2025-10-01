FactoryBot.define do
  factory :campagne do
    sequence(:libelle) { |n| "Ma campagne #{n}" }
    sequence(:code) { |n| "CODE#{n}" }
    association :compte, factory: :compte_admin
    parcours_type
    type_programme { :diagnostic }

    trait :numeratie do
      situations_configurations { build_list(:situation_configuration, 1, :numeratie) }
    end

    trait :litteratie do
      situations_configurations { build_list(:situation_configuration, 1, :litteratie) }
    end

    trait :avec_situations_configurations do
      situations_configurations { build_list(:situation_configuration, 1) }
    end

    trait :avec_parcours_diagnostic do
      association :parcours_type, factory: [ :parcours_type, :diagnostic ]
    end

    trait :avec_parcours_positionnement do
      association :parcours_type, factory: [ :parcours_type, :positionnement ]
    end
  end
end
