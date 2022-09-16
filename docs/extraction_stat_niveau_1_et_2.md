# Comment faire l'extration des stats de niveau 1 et 2 pour les études statistiques de pré-positionnement

## Récupération de la base de prod
ATTENTION : cette commande va écraser votre base de développement (qu'il faudra ensuite réstauré en ré-installant la base de pré-prod)

Télécharger le dernier backup de prod puis :

    pg_restore --verbose --clean --no-acl --no-owner -d eva_development -F c ~/Downloads/20220915220146_eva_serveur_3451.pgsq

## Si vous avez changer d'algo, il faut recalculer les évaluations
(attention, c'est plus d'1 heure 30 de calcule en tout) :

Remarque, la commande `time` n'est pas obligatoire. Elle sert juste à donner le temps d'execution à la fin.

### Recalculer toutes les métriques (45 minutes) :

Dans trois terminaux différents, lancer en simultané les commandes suivantes :

    time bundle exec rake nettoyage:recalcule_metriques SITUATION=livraison
    time bundle exec rake nettoyage:recalcule_metriques SITUATION=maintenance
    time bundle exec rake nettoyage:recalcule_metriques SITUATION=objets_trouves

### Puis recalculer les évaluations (40 minutes) :

    time bundle exec rake evaluations:calcule_restitution

## Extraires les stats :

Lancer la commande suivante en adaptant le nom du fichier pour lui mettre la date et l'heure dans son nom :

    time bundle exec rake stats:niveau_1_et2 | tee 20220816_1556_niveau1et2-algo-v2.1.csv

Puis déplacer le fichier dans le drive par exemple avec la commande suivante si vous avez bien activé un répertoire réseau qui correspond au drive eva :

    mv 20220816_1556_niveau1et2-algo-v2.1.csv /Volumes/GoogleDrive-106668062768583956584/Mon\ Drive/EVA\ -\ Google\ Drive/PRODUIT/\(Lau\)\ Mesures,\ psychométrie,\ et\ statistiques/Mesures\ de\ l\'illettrisme\ et\ exports/En\ cours\ -\ export/

## Prévenir Alexis !
