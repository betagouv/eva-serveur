# Mots de passe des comptes de service

Un compte de service est un identifiant utilisé par un programme, et non saisi
par une personne : l'application qui se connecte à sa base de données, à son
stockage de fichiers, à un service d'envoi d'emails, etc.

## La règle

Tout mot de passe ou secret de service est **généré aléatoirement, avec au moins
32 caractères**. Il n'est jamais choisi à la main.

La règle s'applique à la création du secret et à chaque renouvellement.

## Génération

    $> openssl rand -base64 32

Pour les secrets propres à Rails :

    $> bin/rails secret

Quand le fournisseur génère lui-même le secret (Scalingo, AWS, ProConnect,
Mailjet, Rollbar…), on garde la valeur fournie sans la modifier.

## Stockage

- Les secrets sont enregistrés uniquement dans les variables d'environnement des
  applications Scalingo.
- Aucun secret n'est commité dans le dépôt. Le fichier `.env.template` ne contient
  que des valeurs d'exemple.
- Un secret n'est pas réutilisé d'un environnement à l'autre (production,
  préproduction, review apps).

## Renouvellement

Un secret est régénéré, en suivant la même règle :

- quand une personne qui y avait accès quitte l'équipe ;
- au moindre doute sur sa confidentialité (secret affiché dans un log, envoyé
  dans une messagerie, commité par erreur…).

## Secrets concernés

| Secret | Origine |
|---|---|
| Mot de passe PostgreSQL (`DB_PASSWORD`) | Généré par Scalingo |
| Mot de passe Redis (`REDIS_URL`) | Généré par Scalingo |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | Générés par AWS |
| `PRO_CONNECT_CLIENT_SECRET` | Fourni par ProConnect |
| `MAILJET_API_KEY` / `MAILJET_SECRET_KEY` | Générés par Mailjet |
| `JETON_SERVEUR_ROLLBAR` | Généré par Rollbar |
| `RECAPTCHA_SECRET_KEY` | Généré par Google |
| `METABASE_SECRET_KEY` | Généré par Metabase |
| `RAILS_MASTER_KEY` / `SECRET_KEY_BASE` | Générés par `bin/rails secret` |
| `MOT_DE_PASSE_COMPTES_PREPROD` | Choisi par l'équipe (voir ci-dessous) |

`MOT_DE_PASSE_COMPTES_PREPROD` est le mot de passe appliqué à tous les comptes des
review apps (la tâche `reviewapp:seed` le chiffre avec bcrypt). Il doit respecter
la règle.

## Comptes applicatifs non humains

Les comptes créés par le code (le compte « eva Bot », les comptes de démo)
reçoivent un mot de passe aléatoire généré par `SecureRandom`. Tout nouveau
compte technique doit faire de même : aucun mot de passe en dur dans le code, les
seeds ou les tâches rake.
