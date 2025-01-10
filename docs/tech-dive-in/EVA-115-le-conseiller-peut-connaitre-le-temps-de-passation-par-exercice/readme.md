# EVA-115 : Le conseiller peut connaitre le temps de passation par exercice

[Lien du ticket](https://captive-team.atlassian.net/browse/EVA-115?atlOrigin=eyJpIjoiZmU1MDU4MmFmZmExNGFmNzk5ZDE0NDg4MGE0MmRlZGYiLCJwIjoiaiJ9)

On a deux types d'evenements qui vont nous interesser. Evenements ayant pour nom `affichageQuestionQCM` et `qcm`

Les evenements `affichageQuestionQCM` se crée au moment ou la question se lance dans le front. Et `qcm` est créé au moment de la soumission de la reponse.


## 1 - Calculer le temps passer

On a un fichier `TempsTotal` qui existe et dans lequel on fait le calcul sur differents evenements

Il faudra rajouter une methode de formatage temps total (affichage mm:ss)

```ruby
def format_temps_total
  minutes = temps_total / 60
  seconds = temps_total % 60
  format("%02d:%02d", minutes, seconds)
end
```

## 2 - Afficher le temps passé dans les exports

1 - Recuperer l'evenement `affichageQuestionQCM` rattaché à l'evenement `qcm`

```ruby
# Creer une methode qui va recuperer l'evenement qcm de reponse
def recupere_evenement_affichage_question_qcm
  Evenement.where("donnees ->> 'question' = ?", donnees["question"])
            .where(nom: "affichageQuestionQCM",  session_id: session_id)
            .last
end
```
2 - Afficher l'info dans l'export Litteratie

```ruby
def calcule_temps_passe(evenement)
  evenement_debut = evenement.recupere_evenement_affichage_question_qcm
  temps_total = evenement_debut.nil? ? 0 : evenement.date - evenement_debut.date

  Restitution::Base::TempsTotal.new.format_temps_total(temps_total)
end


def remplis_ligne(ligne, evenement)
  @sheet.row(ligne).replace([evenement.donnees['question'],
                              evenement.donnees['intitule'],
                              evenement.reponse_intitule,
                              # On le passe ici
                              calcule_temps_passe(evenement),
                              evenement.donnees['score'],
                              evenement.donnees['scoreMax'],
                              evenement.donnees['metacompetence']])
  ligne + 1
end
```

3 - Afficher l'info dans l'export Numeratie
```ruby
def calcule_temps_passe(question)
  evenement_reponse = @evenements_reponses.find_by("donnees ->> 'question' = ?", question)
  return if evenement_reponse.nil?

  evenement_qcm = evenement_reponse.recupere_evenement_affichage_question_qcm
  temps_total = evenement_qcm.nil? ? 0 : evenement_reponse.date - evenement_qcm.date

  Restitution::Base::TempsTotal.new.format_temps_total(temps_total)
end

def ligne_data(code, donnees, question)
  [
    code,
    donnees['question'],
    donnees['metacompetence']&.humanize,
    # On affiche ici
    calcule_temps_passe(donnees['question']),
    donnees['score'].to_s,
    donnees['scoreMax'].to_s,
    question&.interaction,
    donnees['intitule']
  ]
end
```