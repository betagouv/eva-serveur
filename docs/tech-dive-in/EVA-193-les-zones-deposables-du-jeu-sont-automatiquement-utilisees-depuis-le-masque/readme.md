<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Les zones déposables du jeu sont automatiquement utilisées depuis le masque

> [EVA-193](https://captive-team.atlassian.net/browse/EVA-193)

## Backend

- Envoyer au front les données nécessaires au paramétrage dans le json d'une question GlisserDeposer
```ruby
    json['zone_depot_url'] = zone_depot if zone_depot.attached?
```
- Restituer le fichier de test `models/question_glisser_deposer_spec.rb` comme avant
- Modifier le type de QuestionGlisserDeposer et envoyé au front le type `glisser-deposer`

# Frontend

- Cleaner les données en dur de `numeratie.js` et `rattrapage.js` qui ne sont plus utiles
- Si question.zone_depot_url retourner l'extensionVue `glisser-deposer-depot-multiple` sinon retourner `glisser-deposer-billets`
- Renommer le composant `GlisserDeposerDepotMultiple` en `GlisserDeposerMultiple`
- Renommer le composant `GlisserDeposerBillets` en `GlisserDeposerSimple`
- Gérer le calcul des points en vérifiant que chaque élement est déposé dans la zone-depot qui contient la class avec le nom technique de la réponse `zone-depot--nomTechniqueReponse`
