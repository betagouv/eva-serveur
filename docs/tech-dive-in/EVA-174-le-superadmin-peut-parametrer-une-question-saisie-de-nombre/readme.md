<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer une question Saisie de nombre

> [EVA-174](https://captive-team.atlassian.net/browse/EVA-174)

## Prérequis

## Backend

1. Permettre au modele QuestionSaisie d'enregistrer un choix de réponse avec un `has_one`

2. Ajouter dans le formulaire d'une QuestionSaisie l'input choix avec la valeur `:bon` par défaut

3. Afficher l'intitulé du choix dans la show d'une QuestionSaisie
