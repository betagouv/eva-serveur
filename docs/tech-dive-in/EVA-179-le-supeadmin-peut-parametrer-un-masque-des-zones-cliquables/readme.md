<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le supeadmin peut paramétrer un masque des zones cliquables

> [EVA-179](https://captive-team.atlassian.net/browse/EVA-179)

## Backend

1. Modifier le modèle QuestionClicDansImage pour rajouter `has_one_attached :zone_cliquable`

2. Contraindre l'upload de svg uniquement
```ruby
  validates :zone_cliquable,
            blob: { content_type: 'image/svg' }
```

2. Modifier le formulaire de QuestionClicDansImage pour rajouter
```ruby
f.input :svg_file, as: :file, hint: "L'un des élément cliquables doit contenir la classe css bonne-reponse"
```

3. Vérifier que le svg contient la class `bonne-reponse` avant sa sauvegarde en bdd

```ruby
  def process_svg_file
    return unless svg_file.attached?

    url = cdn_for(svg_file)
    svg_content = open(url).read
    doc =  Nokogiri::XML(svg_content, nil, 'UTF-8')
    elements_cliquables = doc.css('.bonne-reponse')

    if elements_cliquables.empty?
      errors.add(:svg_file, "doit contenir la classe 'bonne_reponse'")
      throw(:abort)
    end
  end
```

5. Afficher un preview du svg dans la show de QuestionClicDansImage
