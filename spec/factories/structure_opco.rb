FactoryBot.define do
  factory :structure_opco do
    association :structure, factory: :structure_locale
    association :opco
  end
end
