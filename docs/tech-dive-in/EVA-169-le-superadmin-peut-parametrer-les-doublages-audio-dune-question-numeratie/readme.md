<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer les doublages audio d’une question numératie

> [EVA-169](https://captive-team.atlassian.net/browse/EVA-169)

## Prérequis

## Backend

- L'exemple technique dans (https://blog.saeloun.com/2022/06/15/rails-7-extends-audio_tag-and-video_tag-to-accept-active-storage-attachments/) fait référence à "Rails >= 7.1"
- Peut-être besoin d'une mise à jour mineur de rails car on est actuellement sur la version `gem 'rails', '~> 7.0.0'`

- Créer un nouveau modèle `Retranscription`
```ruby
  def change
    create_table :retranscriptions do |t|
      t.string :ecrit
      t.integer :type, default: 0
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end
  end
```

- Permettre de rattacher un audio à une retranscription

```ruby
class Retranscription < ApplicationRecord
  belongs_to :question
  has_one_attached :audio

  enum type: { intitule: 0, modalite_reponse: 1 }
end
```

- Permettre à une question d'avoir plusieurs retranscriptions

```ruby
class Question < ApplicationRecord
  has_many :transcriptions, dependent: :destroy

  accepts_nested_attributes_for :transcriptions, allow_destroy: true
end
```

- Permettre de rattacher un audio à un choix

```ruby
class Choix < ApplicationRecord
  has_one_attached :audio
end
```

- Modifier le formulaire d'une question pour pouvoir ajouter des audios

```ruby
form do |f|
  (...)
  f.has_many :choix, allow_destroy: ->(choix) { can? :destroy, choix } do |c|
    t.input :audio, as: :file, label: 'Upload Audio', input_html: { accept: 'audio/*' }
  end

  f.inputs 'Retranscriptions' do
    f.has_many :transcriptions, allow_destroy: true, new_record: true do |t|
      t.input :ecrit, label: 'Libelle'
      t.input :audio, as: :file, label: 'Upload Audio', input_html: { accept: 'audio/*' }
      ## par défaut le type est libellé
      t.input :type, as: :hidden
    end

    f.has_many :transcriptions, allow_destroy: true, new_record: true do |t|
      t.input :ecrit, label: 'Consigne'
      t.input :audio, as: :file, label: 'Upload Audio', input_html: { accept: 'audio/*' }
      t.input :type, as: :hidden, input_html: { value: 1 }
    end
  end

  f.actions
end
```

- Modifier la show d'une question pour pouvoir écouter les audios

```ruby
panel 'Retranscriptions audios' do
  reorderable_table_for question.retranscriptions do
    column :ecrit
    column :type
    column :audio do
      figure do
        audio_tag(retranscriptions.audio, controls: true)
      end
    end
  end
end
```

## Migration de données

- Faire une migration des anciennes données de Question pour migrer la valeur du champ `ìntitule` dans une nouvelle instance `Retranscription.create(ecrit: question.intitule, question: question)`
- Faire pareil pour le modèle Choix
- Supprimer le champ `intitule` de la table `Question`

--> est-ce que c'est plus prudent de faire une tâche rake ??

- Modifier l'objet json envoyé au front pour les modeles `QuestionQcm`, `QuestionSaisie`, `Choix` et `QuestionSousConsigne`

```ruby
  def as_json(_options = nil)
    retranscription = Retranscription.find_by(type: :intitule, question_id: id)
    json = slice(:id, :nom_technique, :metacompetence, :type_qcm, :description,
                 :choix)
    json['intitule'] = retranscription&.ecrit
    json['type'] = 'qcm'
    json
  end
```
