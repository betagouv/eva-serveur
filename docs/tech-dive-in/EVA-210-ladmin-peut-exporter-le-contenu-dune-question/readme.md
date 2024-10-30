<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# L'admin peut exporter le contenu d'une question

> [EVA-210](https://captive-team.atlassian.net/browse/EVA-210)

## Refacto

- Créer une classe parent `ImportExportQuestion` qui regroupe la logique commune de `ImportExportQuestion` et `ExportQuestion`
- Initialise la classe `ImportExportQuestion` avec une question plutôt qu'un type
- Créer une nouvelle classe `ExportQuestion`

## Backend

1. Ajouter un bouton "Exporter le contenu de la question" sur la show avec un `action_item` dans chaque types de Question
```ruby
  link_to 'Exporter le contenu de la question', admin_export_xls_path(question)
```

2. Ajouter une nouvelle route
```ruby
  resources :questions do
    collection do
      post 'export_xls', defaults: { format: 'xls' }
    end
  end
```

3. Ajouter l'action export_xls dans le `ControllerQuestion`
```ruby
def export_xls
  export = ExportQuestion.new(question)
    send_data export.to_xls,
              content_type: export.content_type_xls,
              filename: export.nom_du_fichier
end
```

4. Créer une nouvelle class `ExportQuestion` et construire les entêtes et valeurs du fichier en fonction du type de Question en respectant l'ordre établi lors de l'import de la question

```ruby
class ExportQuestion
  def initialize(question:)
    @question = question
  end

  def to_xls
    workbook = Spreadsheet::Workbook.new
    sheet = workbook.create_worksheet(name: WORKSHEET_NAME)
    initialise_sheet(sheet)
    remplie_la_feuille(sheet)
    retourne_le_contenu_du_xls(workbook)
  end

  def content_type_xls
    'application/vnd.ms-excel'
  end

  def nom_du_fichier
    date = DateTime.current.strftime('%Y%m%d')
    "#{date}-#{@question.nom_technique}.xls"
  end
end
```

## Inconnu

Comment on gère lorsqu'une question a des has_many ?
-> reprendre le fonctionnemen de l'import avec la même construction de regex
