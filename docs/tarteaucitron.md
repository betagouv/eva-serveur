# Tarte au citron

Tarteaucitron est un gestionnaire de tags RGPD
https://tarteaucitron.io/fr/

Nous maintenont cette dépendence dans notre git dans le répertoire `public/tarteaucitron`

## Mise à jour

Pour mettre à jour, il suffit d'aller chercher le zip de la dernière livraison
sur le dépot github et mettre à jour les fichiers chez nous.

## Test

En dev ou en pré-prod, nous n'activons pas de cookies ce qui fait que la
banière n'apparait pas.  Pour tester en dev, il suffit de définir les variables
système : CRISP_WEBSITE_ID, HOTJAR_ID et/ou MATOMO_ID avant de lancer le serveur.
