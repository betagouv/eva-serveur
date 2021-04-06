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
    nom { 'Ma structure' }
    type_structure { 'mission_locale' }
    code_postal { '75012' }
  end
end
