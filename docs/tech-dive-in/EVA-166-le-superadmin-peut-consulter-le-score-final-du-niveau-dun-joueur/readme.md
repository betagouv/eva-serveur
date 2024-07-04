<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut consulter le score final du niveau d'un joueur

> [KRJ-110](https://captive-team.atlassian.net/browse/EVA-166)

## Prérequis

## Backend

- Modifier la méthode de calcul du score final d'un niveau dans le fichier `/eva-serveur/app/models/restitution/evacob/score_module.rb`


La méthode initial ajoute le scores de tous les évènements réponses

```ruby
  def calcule(evenements, nom_module)
    evenements_filtres = MetriquesHelper.filtre_evenements_reponses(evenements) do |e|
      e.module?(nom_module)
    end
    evenements_filtres.sum(&:score_reponse) if evenements_filtres.present?
  end
```

On va vouloir modifier l'algo pour comparer les questions initial et les question de rattrapage correspondantes pour ne garder que les évènements dont le score total au sein d'un même module est le plus élevé

```ruby
  # Créer un mapping de correspondances pour chaque paire question initial/rattrapage

  MAPPING = {
  'N1Prn' => 'N1Rrn',
  'N1Pde' => 'N1Rde',
  'N1Pes' => 'N1Res',
  'N1Pon' => 'N1Ron',
  'N1Poa' => 'N1Roa',
  'N1Pos' => 'N1Ros'
  }.freeze

  # Modifier la méthode initiale pour filtrer les rattrapage si il y en a

  def calcule(evenements, nom_module, rattrapage = false)
    evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements) do |e|
      e.module?(nom_module)
    end

    return if evenements_reponse.empty?

    evenements_filtres = filtre_rattrapage(evenements_reponse) if rattrapage
    evenements_filtres.sum(&:score_reponse)
  end

  # Ajoute une nouvelle méthode filtre_rattrapage

  def filtre_rattrapage(evenements_reponse)
    score_totaux = Hash.new(0)
    evenements_groupes = Hash.new { |hash, key| hash[key] = [] }

    # Calcul des scores pour chaque paire question/rattrapage
    MAPPING.each do |question, rattrapage|
      evenements_groupes[question] = evenements_reponse.select { |e| e.donnees['question'].start_with?(question) }
      evenements_groupes[rattrapage] = evenements_reponse.select { |e| e.donnees['question'].start_with?(rattrapage) }
      score_totaux[question] = evenements_groupes[question].sum(&:score_reponse)
      score_totaux[rattrapage] = evenements_groupes[rattrapage].sum(&:score_reponse)
    end

    # Trouver la clé avec le score le plus élevé pour chaque paire
    max_score_questions = MAPPING.keys.map do |question|
      [question, MAPPING[question]].max_by { |key| score_totaux[key] }
    end

    # Filtrer les événements pour ne conserver que ceux des catégories avec le score le plus élevé
    max_score_questions.flat_map { |key| evenements_groupes[key] }
  end
end
```

Ajouter la paramètre rattrapage true pour place du marche

```ruby
    def score_niveau1
      Evacob::ScoreModule.new.calcule(evenements, :N1P, rattrapage = true)
    end
```

