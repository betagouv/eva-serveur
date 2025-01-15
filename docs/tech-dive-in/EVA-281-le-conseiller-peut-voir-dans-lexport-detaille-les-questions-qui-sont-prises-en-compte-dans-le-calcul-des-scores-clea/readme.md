# EVA-281 : Le conseiller peut voir dans l'export détaillé les questions qui sont prises en compte dans le calcul des scores cléa

[Lien du ticket](https://captive-team.atlassian.net/browse/EVA-281?atlOrigin=eyJpIjoiMTRiMjMwMWJmMjU5NDU1ZThkZTgwZDRkZWY3ZmI1ZWUiLCJwIjoiaiJ9)

On veut :

`Oui` sur toutes les questions Hors rattrapage (meme celles pas repondues).

`Oui` sur toutes les questions rattrapage repondues.

`Non` sur toutes les questions rattrapage non repondues.


## 1 - Ajouter les entetes 

Dans le fichier `export_donnees.rb` ajouter l'intitulé de la colonne : `Prise en compte dans le calcul du score CléA ?`


## 2 - Recuperer les questions qui servent au calcule de score Clea

On va avoir besoin de comparer la liste des questions (ex: `["N3Pim1", "N3Pim2", "N3Pim3"`) qu'on aura filtré grace a la mthode `filtre_evenements_reponses` et la question de la ligne.

`filtre_evenements_reponses` va nous permettre de recuperer toutes les questions principales (prise en compte dans le calcul repondues ou non) et les questions rattrappage repondues. (On exclus les autres questions de rattrappages non repondues)

Dans le fichier `export_numeratie.rb` on va modifier la methode `remplis_reponses` pour recuperer la liste des questions qu'on utilisera par la suite.

```ruby
def remplis_reponses(ligne, reponses)
  # on recupere la liste des reponses filtrées
  liste_questions = filtre_evenements_reponses(reponses).map { |e| [e['question']] }.flatten

  reponses.each do |reponse|
    question = Question.find_by(nom_technique: reponse['question'])
    # On passe ici la liste que l'on va utiliser par la suite
    ligne = remplis_ligne(ligne, reponse, question, liste_questions)
  end
  ligne
end
```

On va ensuite modifier la methode `remplis_ligne` :

```ruby
# On va lui passer la liste ici qu'on recupere plus haut
def remplis_ligne(ligne, donnees, question, liste_questions)
  est_non_repondu = questions_non_repondues.any? do |q|
    q[:nom_technique] == donnees['question']
  end

  code = Metacompetence.new(donnees['metacompetence']).code_clea_sous_sous_domaine
  # on passe la liste a ligne_data
  row_data = ligne_data(code, donnees, question, liste_questions)
  @sheet.row(ligne).replace(row_data)
  grise_ligne(ligne) if est_non_repondu
  remplis_choix(ligne, donnees, question)
  ligne + 1
end
```

Dans la methode `ligne_data` on va appeler une nouvelle methode qu'on va crée :

```ruby
def ligne_data(code, donnees, question, liste_questions)
  [
    code,
    donnees['question'],
    donnees['metacompetence']&.humanize,
    donnees['score'].to_s,
    donnees['scoreMax'].to_s,
    # Pour l'affichage on appelle notre nouvelle methode (ci-dessous)
    question_pris_en_compte_pour_calcul_score_clea?(liste_questions, donnees['question']),
    question&.interaction,
    donnees['intitule']
  ]
end
```

```ruby
# Nouvelle methode qu'on crée ici

def question_pris_en_compte_pour_calcul_score_clea?(liste_questions, question)
  # On regarde si la question `N3Pim4` est comprise dans la liste
  liste_questions.include?(question) ? "Oui" : "Non"
end
```
