FactoryBot.define do
  factory :donnee_sociodemographique do
    age { 25 }
    genre { 'homme' }
    dernier_niveau_etude { 'pas_etudie' }
    derniere_situation { 'en_emploi' }
    langue_maternelle { 'oui' }
    lieu_scolarite { 'non' }
    vue { 'bienvenue_8_reponse_4' }
    entendre { 'bienvenue_non' }
    trouble_dys { 'bienvenue_non' }
    difficultes_informatique { 'non' }
    evaluation
  end
end
