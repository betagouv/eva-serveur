<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer les images à glisser (avec leur ordre)

> [EVA-185](https://captive-team.atlassian.net/browse/EVA-185)

## Backend

1. Modifier le modèle QuestionGlisserDeposer pour rajouter des reponses
```ruby
  has_many :reponse, class_name: 'Choix', foreign_key: :question_id, dependent: :destroy
  accepts_nested_attributes_for :reponse, allow_destroy: true
```

2. Modifier le modèle choix pour permettre d'ajouter une illustration
```ruby
  has_one_attached :illustration
  ILLUSTRATION_CONTENT_TYPES = ['image/png', 'image/jpeg', 'image/webp'].freeze

  validates :illustration,
            blob: { content_type: ILLUSTRATION_CONTENT_TYPES }
```

3. Refacto la méthode ILLUSTRATION_CONTENT_TYPES pour en faire un helper utilisable partout dans l'app

4. Rajouter le permit params dans `admin/questions_glisser_deposer.rb`
```ruby
  reponse_attributes: %i[id illustration position _destroy nom_technique]
```

5. Modifier le formulaire de QuestionGlisserDeposer pour rajouter la possibilité d'ajouter plusieurs choix avec illustration et position

6. Modifier la show de QuestionGlisserDeposer pour afficher les choix avec leurs illustrations et leurs positions

7. Ajouter un preview des illustrations dans le form update de QuestionGlisserDeposer et la possiblité de les supprimer

8. Modifier le json envoyé au front pour rajouter
- illustration
- modalite réponse
- audio modalité réponse
- intitulé
- audio intitulé
- reponsesNonClasses

## Frontend

1. Renommer la clé `fragmentsNonClasses` en `reponsesNonClasses` partout dans l'app pour que ce soit cohérent avec les notions métiers du back

2. Supprimmer les fakes datas de la question N1Pon1

