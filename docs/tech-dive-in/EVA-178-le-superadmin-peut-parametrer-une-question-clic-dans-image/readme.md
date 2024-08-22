<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer une question clic dans image

> [EVA-178](https://captive-team.atlassian.net/browse/EVA-178)

## Backend

1. Créer un nouveau modèle `QuestionClicDansImage` qui hérite du modèle `Question`

2. Créer le formulaire de QuestionClicDansImage avec les champs suivant :
- illustration
- modalite réponse
- audio modalité réponse
- intitulé
- audio intitulé
- nom technique
- libellé

3. Créer la show de QuestionClicDansImage


## Bonus

-> Renommer la trad “Image du jeu” en “Image de fond de la question”
