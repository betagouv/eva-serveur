FactoryBot.define do
  factory :donnee_sociodemographique do
    age { 25 }
    genre { 'homme' }
    dernier_niveau_etude { 'pas_etudie' }
    derniere_situation { 'en_emploi' }
    langue_maternelle { 'oui' }
    lieu_scolarite { 'non_scolarise' }
    evaluation
  end
end
