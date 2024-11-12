<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer un écran sous-consigne de Café de la Place

> [EVA-226](https://captive-team.atlassian.net/browse/EVA-226)

## Backend

1. Modifier la tâche rake `questions: :attache_assets` et permettre de passer un params supplémentaire `TYPE_QUESTION`
ex : `questions: :attache_assets TYPE_QUESTION=SOUS_CONSIGNE

2. Attache les fichiers spécifiques au type sous_consigne à savoir uniquement un :audio pour l'intitulé et une :illustration pour la question

3. Créer le mapping des illustrations pour les questions sous_consignes

```ruby
NOM_TECHNIQUES_SOUS_CONSIGNES = {
sous_consigne_LOdi_1: "programmeTele",
sous_consigne_LOdi_2: "programmeTeleZoom",
sous_consigne_ALrd_1: "terrasseCafe",
sous_consigne_ALrd_2: "listeTitresMusique",
sous_consigne_ACrd_1: "magazineSansTexte",
sous_consigne_ACrd_2: "magazineSansTexte",
sous_consigne_APlc_1: "terrasseCafe",
sous_consigne_APlc_2: "listeDeCourse",
sous_consigne_HPar_1: "hParConsigne",
sous_consigne_HGac_1: "graphiqueAvecSelection",
sous_consigne_HCvf_1: "rubriqueEnvironnement",
sous_consigne_HPfb_1: "terrasseCafe",
sous_consigne_HPfb_2: "telephoneEMail"
}.freeze
```

## Frontend

1. Créer la première sous consgine dans une migration de donnée pour passer la démo

2. Lancer le script et récupérer l'import des questions sosu consignes de café de la place
