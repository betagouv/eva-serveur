Aujourd'hui, sur Eva on se rapproche de plus en plus du Système de Design de l'État --> https://www.systeme-de-design.gouv.fr/

Ainsi, on a décidé de mettre en place une vue de démo pour chacun de ses composants qu'on va rajouter, car nous sommes sujets à de la customisation.
Pourquoi? car nous utilisons ActiveAdmin et que nous devons contrecarrer la surcouche et faire coïncider nos éléments avec le design existant.

## Comment cela fonctionne?

On va pouvoir créer notre composant dans le fichier component.
Puis dans le controller `ui_kit`, on va pouvoir rajouter une méthode afin d'afficher ce composant tout en créant une vue simple avec tous les variants possibles.

cetet vue sera accessible depuis: 
http://localhost:3000/admin/ui_kit/mon_composant
