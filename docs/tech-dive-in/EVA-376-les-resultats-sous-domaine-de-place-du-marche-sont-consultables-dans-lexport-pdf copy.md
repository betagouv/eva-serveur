# EVA-390-le-conseiller-peut-visualiser-le-resultat-dun-sous-domaine-de-maniere-graphique


### Component
On va faire un composant:
```ruby
class BarreDeProgressionComponent 
  def initialize(reussite:, echec:, non_passees:, total:)
    @reussite = reussite
    @echec = echec
    @non_passees = non_passees
    @total = total # (100%)
  end
end
```

au niveau de la vue je pensais à qqch dans le genre:
```html
<div class="progress-bar-container">
  <div class="progress-bar">
    <div class="progress-segment progress-success" style="width: <%= pourcentage_reussite %>%"></div>
    <div class="progress-segment progress-failure" style="width: <%= pourcentage_echec %>%"></div>
    <div class="progress-segment progress-missing" style="width: <%= pourcentage_non_passees %>%"></div>
  </div>
  <p class="progress-legend">
    <strong>Réussite :</strong> <%= @reussite %> - 
    <strong>Échec :</strong> <%= @echec %> - 
    <strong>Non passés :</strong> <%= @non_passees %> - 
    <strong>Total :</strong> <%= @total %>
  </p>
</div>
```

On appelerai le composant comme ça:

<%= render BarreDeProgressionComponent.new(
  reussite: pourcentage(@objet_sous_competence.nombre_questions_reussies),
  echec: pourcentage(@objet_sous_competence.nombre_questions_echouees),
  non_passees: pourcentage(@objet_sous_competence.nombre_questions_non_passees)
) %>

Je vais récupérer mes questions depuis place_du_marche:
je pensais juste ajouter 2 pour récupérer le % en echec et le % non passées, de la meme manière qu'on a la pourcentage de réussite
