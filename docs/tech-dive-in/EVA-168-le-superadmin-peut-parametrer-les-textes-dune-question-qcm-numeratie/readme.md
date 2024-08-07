<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Click on Image

> [EVA-43](https://captive-team.atlassian.net/browse/EVA-168)

## Backend

- Ajoute le fichier `app/admin/questions.rb` pour le modèle existant `Question`

```ruby
ActiveAdmin.register Question do
  menu parent: 'Parcours', if: proc { current_compte.superadmin? }

  permit_params :libelle, :nom_technique, :intitule, :consigne,
  choix_attributes: %i[id intitule type_choix _destroy nom_technique]

  filter :libelle

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :type
      f.input :libelle
      f.input :nom_technique
      f.input :intitule
      f.input :consigne
      f.has_many :choix, allow_destroy: ->(choix) { can? :destroy, choix } do |c|
        c.input :id, as: :hidden
        c.input :intitule
        c.input :nom_technique
        c.input :type_choix
      end
    end
    f.actions do
      f.action :submit
      annulation_formulaire(f)
    end
  end

  index do
    column :libelle
    column :created_at
    column :type
    actions
  end

  show do
    render partial: 'show'
  end
end
```

- Créer une nouvelle migration pour ajouter le champ `consigne` au modèle Question existant
- Ajouter un `enum :type` au modèle Question avec tous les types existants pour obtenir un select dans le formulaire
- Ajouter la liaison avec les choix

```ruby
  TYPES = %i[QuestionQcm QuestionSaisie].freeze
  enum :type, TYPES.zip(TYPES.map(&:to_s)).to_h, prefix: true

  has_many :choix, lambda {
    order(position: :asc)
  }, foreign_key: :question_id,
     dependent: :destroy

  accepts_nested_attributes_for :choix, allow_destroy: true
```

- Changer la trad `libellé` pour `libellé de la question` et rajouter la légende `Telle qu’elle sera écrite dans le jeu` en dessous du champ
- Mettre le placeholder `N1Prn1` pour le nom technique
- Créer la partial `admin/questions/show`

- Gérer avec un script javascript comme pour la création d'une campagne l'affichage du champ `choix` uniquement une fois que l'utilisateur sélectionne `type: qcm`

