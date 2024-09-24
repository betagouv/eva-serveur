<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le superadmin peut paramétrer une question glisser deposer

> [EVA-186](https://captive-team.atlassian.net/browse/EVA-186)

## Backend

1. Rajouter une `has_many_attached :zones_depot_url` de type svg dans `QuestionGlisserDeposer`
2. Rajouter une validation de presence sur ce model pour la zone sur ce model
3. Vérifier que le svg contient la class `bonne-reponse` avant sa sauvegarde en bdd
```ruby
def valide_zones_depot_url_avec_reponse
  return unless zones_depot_url.attached?
  return if attachment_changes['zones_depot_url'].nil?

  attachment_changes['zones_depot_url'].attachable.each do |file|
    doc = Nokogiri::XML(file.download, nil, 'UTF-8')
    
    elements_zone_depot = doc.css(".zone-depot")
    elements_technique = doc.css(".zone-depot--#{reponse.nom_technique}")

    if elements_zone_depot.empty? || elements_technique.empty?
      errors.add(:zones_depot_url, "doit contenir les classes 'zone-depot' et 'zone-depot--#{reponse.nom_technique}'")
      throw(:abort)
    end
  end
end
```
5. Ajouter un `supprimer_zones_depot_url` de la même manière que zone cliquable
6. Afficher un preview du svg dans la show de `QuestionGlisserDeposer` + un hint pour le format
''