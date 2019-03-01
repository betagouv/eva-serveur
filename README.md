# Compétences Pro Serveur

Cette application sert de serveur et d'espace d'administration pour la startup [Compétences Pro](https://github.com/betagouv/competences-pro)

## Adresse du serveur
https://competences-pro-serveur.scalingo.io

* Accès admin : https://competences-pro-serveur.scalingo.io/admin
* Point d'API : https://competences-pro-serveur.scalingo.io/api

## Environnement Technique

* Ruby version
2.5.3

* System dependencies
PostgreSql

* Configuration
RAS pour le moment

* Database creation
`rake db:create`

* Database initialization
`rake db:migrate` && `rake db:seed`

* How to run the test suite
```
bundle exec rake spec
```

* Services (job queues, cache servers, search engines, etc.)
RAS pour le moment

* Deployment instructions
Pour déployer manuellement sur Scalingo Staging, ajouter le remote `git`

```
git remote add scalingo git@scalingo.com:competences-pro-serveur.git
```

Puis lancer le déploiement avec `git` :

```
git push scalingo master
```


* Espace d'administration
accessible à l'url `/admin`, un compte admin est créé avec l'execution du seed. À ce jour le compte créé est `administrateur@exemple.com` avec le mot de passe `password` (pour le développement seulement bien sûr ;-))

## API

L'api est accessible au point `/api`

### Evenements

* Path : `/api/evenements`
* Méthod : `POST`
* Format du body :
```
{
  "evenement": {
    "date": 1551111089238,
    "type_evenement": "ouvertureContent",
    "description": "{'idContenu':'6','type':'ContenantUnitaire','forme':'caisse','quantite':1,'couleur':'gris','posX':52.4,'posY':25.9,'contenu':{'nom':'Terra Cola','image':'/assets/terracola.png?24jVUPB'},'largeur':16.3,'hauteur':9}"
  }
}
```

## Licence

Ce logiciel et son code source sont distribués sous [licence AGPL](https://www.gnu.org/licenses/why-affero-gpl.fr.html).

