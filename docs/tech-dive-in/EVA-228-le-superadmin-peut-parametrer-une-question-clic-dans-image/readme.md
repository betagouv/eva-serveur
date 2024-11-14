<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer une question Clic dans texte

> [EVA-228](https://captive-team.atlassian.net/browse/EVA-228)

# 🎯 Résultat à atteindre

On veut récupérer toutes les questions clic dans texte utilisées dans la littéracie.
Le super admin doit pouvoir paramétrer le texte à lire dans la question :

- Peut éditer dans l’admin l’ensemble du texte qui sera affiché dans le jeu
- Ajouter un champs Contenu texte → On le met après avoir renseigné intitulé et consigne
- Dans ce champs l’admin peut entrer le texte en markdown
- Peut éditer dans l’admin les mots du texte qui sont cliquables → dans le markdown
- Peut indiquer dans l’admin les mots cliquables qui sont les bonnes réponses → dans le markdown
- Peut choisir l’image de fond de la question
→ On reprend les champs de base comme pour les autres questions : Libéllé, nom technique, intitulé
- Créer les questions clics dans texte de la littéracie dans le backoffice
On traite la partie jeu dans un ticket à part. Ici, on veut juste le paramétrage des questions

## Étapes

1. Créer un model QuestionClicDansTexte

- Hérite de Question
- Ajouter un champ `texte_sur_illustration` à Question (migration)
- Hint afin d'expliquer qu'on rentrer du markdown avec le [toto]() avec le cheatsheet ou SimpleMDE + indiquer que par () = mauvaise réponse et (#bonne-reponse)
- Validation de presence
- reprendre le `has_attached :illustration` de Question
  
2. Définir les mots cliquables
[toto]()

3. Définir les bonnes réponses
[toto](#bonne-reponse)  
[pas toto]()