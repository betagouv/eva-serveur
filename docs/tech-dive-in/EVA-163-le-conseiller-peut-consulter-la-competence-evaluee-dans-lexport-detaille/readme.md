<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le conseiller peut consulter le profil numératie du positionnement dans son espace admin

> [EVA-43](https://captive-team.atlassian.net/browse/EVA-163)

## Backend

Pour rendre plus générique l'export et commun à cafe de la place et place du marché :
- Renommer l'export `ExportCafeDeLaPlace` en export `ExportPositionnement`
- Modifier la route :
```ruby
  resources :parties do
    namespace :cafe_de_la_place do
      resource :reponses, only: [:show], defaults: { format: 'xls' }
    end
  end
```

par

```ruby
  resources :parties do
    namespace :positionnement do
      resource :reponses, only: [:show], defaults: { format: 'xls' }
    end
  end
```

- Modifier la show dans le controller pour récupérer un array d'id au lieu d'un seul
```ruby
  def show
    partie = Partie.find(params[:partie_id])
    redirect_to root_path unless Ability.new(current_compte).can?(:read, partie.evaluation)
    export = ::Restitution::ExportCafeDeLaPlace.new(partie: partie)
    send_data export.to_xls,
              content_type: 'application/vnd.ms-excel',
              filename: nom_du_fichier(partie)
  end
```

```ruby
  def show
    partie_numeratie = Partie.find(params[:partie_numeratie_id])
    partie_litteratie = Partie.find(params[:partie_litteratie_id])
    redirect_to root_path unless Ability.new(current_compte).can?(:read, partie_numeratie.evaluation) &&
      Ability.new(current_compte).can?(:read, partie_litteratie.evaluation)
    export = ::Restitution::ExportPositionnement.new(partie_numeratie: partie_numeratie, partie_litteratie: partie_litteratie)
    send_data export.to_xls,
              content_type: 'application/vnd.ms-excel',
              filename: nom_du_fichier(partie_numeratie, partie_litteratie)
  end
```

- Modifier la la classe `ExportPositionnement`
```ruby
  def initialize(partie_litteratie:, partie_numeratie:)
    @partie_litteratie = partie_litteratie
    @partie_numeratie = partie_numeratie
  end
```

```ruby
  def remplie_la_feuille(sheet)
    ligne = 1
    evenements = Evenement.where(session_id: @partie_litteratie.session_id)
    evenements << Evenement.where(session_id: @partie_numeratie.session_id)
    evenements.reponses.order(position: :asc).each do |evenement|
      sheet = remplis_la_ligne(sheet, ligne, evenement)
      ligne += 1
    end
    ligne
  end
```

- Modifier les endroits où on appelait l'ancienne route `admin_partie_cafe_de_la_place_reponses_path`
 en lui passant les deux params `partie_numeratie_id` et `partie_litteratie_id`

- Sortir l'encart `télécharger le détail des réponses` du bloc lettrisme car il faut qu'il apparaisse même si la situation cafe de la place n'est pas dans la restitution

--> valider avec l'équipe PO le design

## Frontend

- Ajouter la clé `metacompetence` pour chaque question de place du marche
