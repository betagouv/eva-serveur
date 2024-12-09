<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le conseiller peut connaitre le résultat par sous-compétence Cléa en numératie dans l'export détaillé

> [EVA-112](https://captive-team.atlassian.net/browse/EVA-112)

## Refacto

1. Extraire le code spécifique à l'export positionnement littératie et l'export numératie :
`Restitution::Positionnement::ExportLitteratie`
`Restitution::Positionnement::ExportNumeratie`

2. Garder les méthodes communes à la création de l'export positionnement dans un troisième fichier :
`Restitution::Positionnement::Export`

## Backend

1. Ajoute un niveau à l'objet CORRESPONDANCES_CODECLEA pour classer par sous-compétence cléa tout en gardant la classification par sous-sous-compétence

```ruby
  CORRESPONDANCES_CODECLEA = {
    '2.1' => {
      '2.1.1' => %w[operations_addition operations_soustraction operations_multiplication
                    operations_division],
      '2.1.2' => %w[denombrement],
      '2.1.3' => %w[ordonner_nombres_entiers ordonner_nombres_decimaux operations_nombres_entiers],
      '2.1.4' => %w[estimation],
      '2.1.7' => %w[proportionnalite]
    },
    '2.2' => {
      '2.2.1' => %w[resolution_de_probleme],
      '2.2.2' => %w[pourcentages]
    },
    '2.3' => {
      '2.3.1' => %w[unites_temps unites_de_temps_conversions],
      '2.3.2' => %w[plannings plannings_calculs],
      '2.3.3' => %w[renseigner_horaires],
      '2.3.4' => %w[unites_de_mesure instruments_de_mesure],
      '2.3.5' => %w[tableaux_graphiques],
      '2.3.7' => %w[surfaces perimetres perimetres_surfaces volumes]
    },
    '2.4' => {
      '2.4.1' => %w[lecture_plan]
    },
    '2.5' => {
      '2.5.3' => %w[situation_dans_lespace reconnaitre_les_nombres reconaitre_les_nombres
                    vocabulaire_numeracie]
    }
  }.freeze
```

2. Modifier la méthode `regroupe_par_code_clea` pour suivre le nouveau modèle de données de `CORRESPONDANCES_CODECLEA` et classer les questions répondues et non répondues par sous-compétence et par sous-sous-compétence

3. Remplir la feuille en itérant sur les sous compétence et les sous sous compétences

```ruby
regroupe_par_code_clea.each do |sous_code, sous_sous_codes|
  @sheet[ligne, 0] = "#{sous_code} - score: #{pourcentage_reussite}"
  ligne += 1
  sous_sous_codes.each do |code, evenements|
    @sheet[ligne, 0] = "#{code} - score: #{pourcentage_reussite(evenements)}"
    ligne += 1
    ligne = remplis_reponses_par_code(ligne, evenements, code)
  end
end
```

4. Récuperer les pourcentage de réussite des sous-sous-domaine et calculer le % de réussite pour chaque sous domaine

5. Récupérer les intitulés des sous sous compétences dans le document ci-dessous :
https://www.certificat-clea.fr/media/2021/07/Referentiel-Clea_2021.pdf

et mapper les correspondances.
