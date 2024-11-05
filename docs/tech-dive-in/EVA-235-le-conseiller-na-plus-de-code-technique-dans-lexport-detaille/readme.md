<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le conseiller n'a plus de code technique dans l'export détaillé

> [EVA-235](https://captive-team.atlassian.net/browse/EVA-235)

## Challenge

Ajouter de la spécifité à `ExportPositionnement` pour l'export de la numératie sans en extraire la logique propre à l'export Littératie dans une classe à part car dans quelques mois on aura le même export pour Littératie et Numératie.

## Backend

1. Extraire la logique de l'initialisation des entêtes et du remplissage des ligne de `to_xls` propre à l'export de la littératie pour créer une nouvelle méthode `litteratie_to_xls`

2. Construire une nouvelle méthode `numeratie_to_xls` pour initialiser les entêtes et remplir les lignes spécifiquement pour la numératie avec les champs suivants dans l'ordre :
- Code cléa
- Item
- Meta compétence
- Interaction
- Intitulé de la question
- Réponses possibles
- Réponse attendue
- Réponse du bénéficiaire
- Score attribué
- Score possible de la question
