# procédure de ré-initialisation de la base de développement

## création de la base et initialisation du schéma
    bin/reset_db_dev.sh

## initialisation des mots de passe des comptes
    psql eva_development < <prendre le fichier des comptes qui se trouve sur le drive>

# Procédure de ré-initialisation de la base de pre-prod

Pour l'instant le script `reset_db_dev.sh` ne peut pas être appliqué à la pré-prod directement.
Il faut executer les requêtes du fichier `db_preprod.pgsql` en utilisant pgsql, après avoir ouvert un tunel ssl avec la pré-prod.

La procédure est expliqué sur le dashboard scalingo de la base de pré-prod.
L'url de connexion peut être récupérée avec la commande suivante :

    scalingo --app eva-serveur-preprod env | grep POSTGRESQL

