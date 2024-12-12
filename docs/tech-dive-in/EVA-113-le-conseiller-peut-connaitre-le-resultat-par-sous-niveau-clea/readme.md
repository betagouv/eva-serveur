<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le conseiller peut connaitre le résultat par sous-niveau clea

> [EVA-113](https://captive-team.atlassian.net/browse/EVA-113)

## Backend

1. Réfactorer et créer une partial en reprenant `lettrisme-sous-competences` et l'ajouter à `numeratie.erb` en itérant sur `place_du_marche.competences_numeratie`
```html
  <div class="lettrisme-sous-competences">
    <% place_du_marche.competences_numeratie.each do |code_clea, score| %>
      competence = Metacompetence::CODECLEA_INTITULES[code_clea]
      <%= render 'positionnement_sous_competence', sous_competence: competence, profil: score %>
    <% end %>
  </div>
```

2. Récupérer les score et calculer les pourcentages de réussite des sous compétences cléa dès la restitution et non plus au moment de l'export.

- Regrouper les évènements réponses et les questions non répondues par code cléa dans le fichier `place_du_marche.rb` en migrant toute la logique liée à `regroupe_par_codes_clea` de `export_numeratie.rb`.
- Ajouter une variable `groupes_clea` dans l'initialisation pour stocker la liste
- Ajouter les métriques par codes cléa des sous domaines avec les seuils et pourcantages de réussite

```ruby
  METRIQUES = {
    '2.1': {
      pourcentage_reussite: => Evacob::Numeratie::ScoreModule.new,
      seuil: => 75,
      succes: false
    },
    '2.2': {
      pourcentage_reussite: => Evacob::Numeratie::ScoreModule.new,
      seuil: => 50,
      succes: false
    },
    (...)
  }.freeze

  ## après l'initialisation
  METRIQUES.each_key do |metrique|
    define_method metrique do
      METRIQUES[metrique]['pourcentage_reussite'].calcule_pourcentage_reussite(groupes_clea, METRIQUES[metrique])
    end
  end
```

- Calculer les pourcentage de réussite dans `score_module.rb` et les attribuer à `competences_numeratie` dans `place_du_marche.rb`
```ruby
  def calcule_pourcentage_reussite(groupes_clea, code_clea)
    reponses = groupes_clea[code_clea].values.flatten
    scores = reponses.map { |e| [e['scoreMax'] || 0, e['score'] || 0] }
    score_max, score = scores.transpose.map(&:sum)
    score_max.zero? ? nil : (score.to_f * 100 / score_max.to_f).round
  end
```
```ruby
  def competences_numeratie
    @competences_numeratie ||= {
      '2_1': METRIQUES['2_1'][:pourcentage_reussite],
      '2_2': METRIQUES['2_2'][:pourcentage_reussite],
      (...)
    }
  end

  def succes?(code_clea)
    METRIQUES[code_clea][succes]
  end
```

3. Cleaner l'export numératie et récupérer les pourcentages de réussite

4. Gérer l'affichage des sous sous domaine cléa
- Ajouter les trad numératie pour `t(".#{sous_competence}.titre")` et `t(".#{sous_competence}.#{succes}.description")`
- Rendre dynamique l'affichage de la première col.
-> Si littératie -> render `ìmage_tag`
-> sinon render un composant custom qui va être le pourcentage de réussite entouré d'un cercle (pas de maquette)
- Gérer la couleur du cercle en succes ou warning en fonction de `succes?(code_clea)`
```scss
{
  warning: $eva_orange
  succes: $eva_green
}
```
