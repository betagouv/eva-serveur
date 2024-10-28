<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# L'admin peut importer le contenu d'une question

> [EVA-209](https://captive-team.atlassian.net/browse/EVA-209)

## Backend

1. Ajouter un bouton dans le panneau de gestion de QuestionClicDansImage avec une nouvelle route custom

```ruby
  action_item :importer_question, only: :index, if: -> { can? :manage, Question } do
    link_to 'Importer question clic dans image', admin_import_csv_questions_path
  end
```

```ruby
namespace :admin do
  resources :questions do
    collection do
      get 'import_csv'
      post 'prefill_from_csv'
    end
  end
end
```

2. En cliquant ça ouvre un nouveau formulaire pour uploader le csv `admin/views/questions_clic_dans_image/import_csv.html.erb`

```ruby
<%= form_with admin_prefill_from_csv_questions_path, method: :post do |f| %>
  <%= file_field_tag :file, accept: '.csv' %>
  <%= f.submit 'Télécharger le fichier' %>
<% end %>
```

3. Ajouter la méthode import_csv au modèle QuestionClicDansImage avec les champs correpondants

- Gérer les contenus string et integer :
```ruby
def self.import_csv(file)
    spreadsheet = Spreadsheet.open(file.path)
    sheet = spreadsheet.worksheet(0)

    sheet.each_with_index do |row, index|
      next if index.zero?

      question = QuestionClicDansImage.create(
        libelle: row['libelle'],
        nom_technique: row['nom technique'],
        description: row['description'],
      )
      ## Intitule
      Transcription.new(
        ecrit: row['intitulé'],
        question_id: question.id
      )
      ## Consigne
      Transcription.new(
        ecrit: row['consigne'],
        question_id: question.id
      )
    end
  end
```

- Gérer les attachments en passant les path dans le csv pour :illustration, :zone_cliquable, :audio_intitule, :audio_consigne, :image_au_clic

```ruby
  illustration_path = row['illustration']
  if illustration_path.present? && File.exist?(illustration_path)
    question.illustration.attach(io: File.open(illustration_path), filename: File.basename(illustration_path))
  end
```



4. Ajouter une méthode `prefill_from_csv` dans le controller QuestionClicDansImage
```ruby
def prefill_from_csv
  if params[:file].present?
  ## Redirige vers le form d'une question clic dans image
    Question.import_csv(params[:file])
    redirect_to edit_admin_question_clic_dans_image_path
  else
  ## Reste sur le form et déclenche une erreur
    throw(:abort)
  end
end
```

5. Réitérer pour les autres types de questions avec les champs et redirections correspondantes

##Inconnu

Trouver une manière sécurisée de cibler les bon row du fichier csvpour les attribuer aux champs correspondants. Utilisation de symbole possible plutôt que de string/index ?
