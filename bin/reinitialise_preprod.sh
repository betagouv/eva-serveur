#!/bin/bash -x

# Lancé chaque semaine par le planificateur Scalingo (cron.json), qui
# l'exécute sur toutes les applications déployées depuis ce dépôt :
# seule eva-serveur-preprod doit être réinitialisée.
if [[ "$APP" != "eva-serveur-preprod" ]] ; then
  echo "Réinitialisation ignorée sur $APP"
  exit 0
fi

set -e

bundle exec rake reviewapp:videdb
bin/reviewappdeploy.sh
