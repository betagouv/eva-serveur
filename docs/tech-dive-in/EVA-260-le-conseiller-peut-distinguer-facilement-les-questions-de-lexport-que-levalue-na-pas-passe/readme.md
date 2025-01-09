# EVA-260 : Le conseiller peut distinguer facilement les questions de l'export que l'évalué n'a pas passé

[Lien du ticket](https://captive-team.atlassian.net/browse/EVA-260)

Modifié la méthode `remplis_ligne` et ajouter une méthode pour appliquer le style dans Worksheet:


Dans export numeratie faire qqch comme:
```ruby
  def remplis_ligne(ligne, donnees, question)
    est_non_repondu = questions_non_repondues.any? { |q| q[:nom_technique] == donnees['question'] }
    code = Metacompetence.new(donnees['metacompetence']).code_clea_sous_sous_domaine
    row_data = ligne_data(code, donnees, question)
    @sheet.row(ligne).replace(row_data)
    grise_ligne(ligne) if est_non_repondu
    remplis_choix(ligne, donnees, question)
    ligne + 1
  end
```

dans Worksheet:
```ruby
  def applique_style_ligne(ligne, style)
    @sheet.row(ligne).default_format = style
  end
```