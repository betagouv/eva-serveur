## Récupération de la version à déployer
En local, je récupère la dernières versions de la branche dévelop.

    $> git checkout develop
    $> git pull

## Taggage

    $> git tag vYYYYMMDD
    $> git push --tags

## Merge de la version sur master

    $> git checkout master
    $> git pull
    $> git merge vYYYYMMDD

## Contrôle

Controle de ce qui va être déployé :

    $> git log --oneline --graph

Vérification de l'activité de la prod :

Je regarde en prod sur https://pro.eva.anlci.gouv.fr/admin/dashboard s'il n'y a pas l'air d'avoir une évaluation en cours
Je regarde aussi l'activité du serveur sur scalingo

## Déploiement

    $> git push

## Création de la Release sur Github

Sur github, je créé une release à partir du tag. Cette documentation peut très
bien se faire avant le déploiement, juste après l'étape de Contrôle
