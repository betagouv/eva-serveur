# Le superadmin peut paramétrer une aide pour une question Saisie

> [EVA-250](https://captive-team.atlassian.net/browse/EVA-250)

## 🎯 Résultat à atteindre

Du point de vue fonctionnel, qu'est-ce qu'on veut pouvoir observer.  
A la création/édition d’une question Saisie :  
Ajouter un champs “Aide”  
Champs texte  
Exemple d’aide pour les questions du niveau 3 :  
Calcul de la surface d’un triangle  
S = (base x hauteur) ÷ 2  
S = (b x h) ÷ 2  
Il faut qu’on puisse sauter des lignes et que ce soit pris en compte quand on fera le front

### Étapes :

1. Ajouter une colonne `aide` à la table `Question` type text
2. Ajouter cette colonne au json à renvoyer au front
3. Ajouter dans l'admin le champs aide, je propose en markdown pour gérer les saut de lignes de la même façon qu'une `QuestionClicDansTexte` (avec le wysiwyg markdown)

