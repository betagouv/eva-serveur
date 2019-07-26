# Compétences Pro Serveur

Cette application sert de serveur et d'espace d'administration pour [Compétences Pro](https://github.com/betagouv/competences-pro)

* Ruby version
2.6

* Base de données
PostgreSql

* Création de la base
`rake db:create`

* Initialisation de la base
`rake db:migrate` && `rake db:seed`

Avant de pouvoir commencer des tests utilisateurs, il vous faut créer une campagne avec l'interface d'administration décrite ci-dessous.

* Lancer les tests
`bundle exec rake spec` ou `guard`

* Espace d'administration
accessible à l'url `/admin`, un compte admin est créé avec l'execution du seed. À ce jour le compte créé est `administrateur@exemple.com` avec le mot de passe `password` (pour le développement seulement bien sûr ;-))

## API

L'api est accessible au point `/api`

### Crée une évaluation

**Requête**

`POST /api/evaluations`

```
{
  "nom": "Roger",
  "code_campagne": "Mon code de campagne"
}
```

**Réponse**

```
{
  "id:": 1,
  "nom": "Roger"
}
```

### Récupére des informations sur l'évaluation

**Requête**

`GET /api/evaluations/:id`

**Réponse**

```
{
  "questions:": [
    {
      id: 1,
      type: 'qcm',
      intitule: 'Ma question',
      description: 'Ma description',
      choix: []
    }
  ],
  "situations": [
    {
      "id": 1,
      "libelle": "Tri",
      "nom_technique": "tri"
    }
  ]
}
```

### Crée un événement

`POST /api/evenements`

Contenu:

```
{
  "date": 1551111089238,
  "nom": "ouvertureContenant",
  "session_id": "baf2c86c-6c34-11e9-901c-c34362f7423a",
  "situation": "inventaire",
  "donnees": {"idContenu": "6"},
  "evaluation_id": "1",
}
```

## Licence

Ce logiciel et son code source sont distribués sous [licence AGPL](https://www.gnu.org/licenses/why-affero-gpl.fr.html).
