Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'coordinates' => [ 40.7143528, -74.0059731 ]
    }
  ]
)

FactoryBot.define do
  factory :structure do
    sequence(:nom) { |n| "structure #{n}" }
    type_structure { 'mission_locale' }
    code_postal { '75012' }
    latitude { 40.7143528 }
    longitude { -74.0059731 }
    sequence(:siret) { |n| format('%014d', n) }
    type { 'StructureLocale' }


    trait :avec_admin do
      after(:create) do |structure|
        create(:compte_admin, structure: structure)
      end
    end

    factory :structure_locale, class: StructureLocale.to_s do
      type { 'StructureLocale' }

      trait :eva_pro do
        usage { AvecUsage::USAGE_EVAPRO }
        association :opco
      end

      trait :beneficiaire do
        usage { AvecUsage::USAGE_BENEFICIAIRES }
      end
    end

    factory :structure_administrative, class: StructureAdministrative.to_s do
      type { 'StructureAdministrative' }
    end

    factory :structure_opco, class: StructureOpco.to_s do
      type { 'StructureOpco' }
      association :opco
    end
  end
end
