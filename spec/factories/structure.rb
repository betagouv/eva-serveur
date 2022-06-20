# frozen_string_literal: true

Geocoder::Lookup::Test.set_default_stub(
  [
    {
      'coordinates' => [40.7143528, -74.0059731]
    }
  ]
)

FactoryBot.define do
  factory :structure do
    sequence(:nom) { |n| "structure #{n}" }
    type_structure { 'mission_locale' }
    code_postal { '75012' }

    trait :avec_admin do
      after(:create) do |structure|
        create(:compte_admin, structure: structure)
      end
    end

    factory :structure_locale, class: StructureLocale.to_s
    factory :structure_administrative, class: StructureAdministrative.to_s
  end
end
