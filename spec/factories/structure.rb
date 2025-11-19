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
    siret { '12345678901234' }
    type { 'StructureLocale' }


    trait :avec_admin do
      after(:create) do |structure|
        create(:compte_admin, structure: structure)
      end
    end

    factory :structure_locale, class: StructureLocale.to_s do
      type { 'StructureLocale' }
    end
    factory :structure_administrative, class: StructureAdministrative.to_s do
      type { 'StructureAdministrative' }
    end
  end
end
