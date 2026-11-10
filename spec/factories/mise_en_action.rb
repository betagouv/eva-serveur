FactoryBot.define do
  factory :mise_en_action do
    evaluation
    beneficiaire { evaluation.beneficiaire }
    structure { evaluation.structure }
    effectuee { true }
    repondue_le { Time.zone.now }
  end
end
