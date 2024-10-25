<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le conseiller peut consulter le %age de bonnes réponses par code Cléa

> [EVA-234](https://captive-team.atlassian.net/browse/EVA-234)

## Backend

1. Trier l'export xls par ordre croissant de code cléa

2. Modifier l'export xls pour passer une ligne entre chaque nouveau code cléa et ajouter le sous-sous-domaine correspondant dans la première cellule

3. Calculer le pourcentage de réussite d'un sous domaine

```ruby
scoreMax += evenement.donnees['scoreMax']
scoreSousDomaine += evenement.donnees['score']
pourcentage_reussite = scoreSousDomaine / scoreSousDomaine * 100
```
