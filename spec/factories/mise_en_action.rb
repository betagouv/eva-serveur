FactoryBot.define do
  factory :mise_en_action do
    evaluation
    effectuee { true }
    repondue_le { Time.zone.now }
  end
end
