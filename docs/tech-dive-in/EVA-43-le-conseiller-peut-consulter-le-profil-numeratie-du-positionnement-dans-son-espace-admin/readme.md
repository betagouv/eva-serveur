<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Le conseiller peut consulter le profil numératie du positionnement dans son espace admin

> [EVA-43](https://captive-team.atlassian.net/browse/EVA-43)

## Contexte

L’algo qui permet de calculer les profils de la litteratie se sert de seuils fixes pour déterminer le profil d'un niveau. Par exemple pour la lecture :
si score >= 15, on attribue le profil 4
si score >= 11, on attribue le profil 3
Ect...

## Solutions envisagées

1. Si on veut garder le même fonctionnement, il va falloir implémenter toutes les questions de tous les niveaux pour que l’algo fonctionne et que le nombre de points par niveau soit fixe.
2. Si on veut un fonctionnement plus dynamique qui s’adapte peut importe le nombre de questions et le nombre de points, il va falloir créer un nouvel algo et potentiellement aligner le calcul de la littératie sur celui-ci.
3. Ou alors on considère que les méthodes de calculs de la littératie et de la numératie sont différentes et on garde deux algo différents.

Après avoir sondé l'équipe produit, on veut pouvoir déterminer la réussite ou non d'un niveau peu importe le nombre de questions. On part donc sur l'implémentation 3.

## Frontend
- Ajouter le score max pour chaque évènement réponse dans `/place_du_marche/modeles/store.js`
```javascript
enregistreReponse(state, reponse) {
  (...)

  reponses[question] = reponse;
  reponses[question].score_max = carteActive.score;
  reponses[question].score = succes ? carteActive.score : 0;

  (...)
},
```
## Backend

- Récupérer le score max de chaque évènement réponse et calculer le score max d'un niveau
- Ajouter le helper `score_max_reponse`dans `/decorators/evenement_place_du_marche.rb`

```ruby
  def score_max_reponse
    donnees['score_max'] || 0
  end
```

- Ajouter la fonction `calcule_max` dans le fichier `/restitution/evacob/score_module.rb`

```ruby
  def calcule(evenements, nom_module, avec_rattrapage: false)
    recupere_evenements_reponses_filtres(evenements)
    e_filtres.sum(&:score_reponse)
  end

  def calcule_max(evenements, nom_module, avec_rattrapage: false)
    recupere_evenements_reponses_filtres(evenements)
    e_filtres.sum(&:score_max_reponse)
  end

  def recupere_evenements_reponses_filtres(evenements)
    evenements_reponse = MetriquesHelper.filtre_evenements_reponses(evenements) do |e|
      e.module?(nom_module)
    end

    return if evenements_reponse.empty?

    e_filtres = avec_rattrapage ? filtre_rattrapage(evenements_reponse) : evenements_reponse
  end
```

- Déterminer le pourcentage de réussite pour chaque niveau dans la restitution `/restitution/place_du_marche.rb`

```ruby
  METRIQUES = {
    'score_niveau1' => {
      'type' => :nombre,
      'parametre' => :N1,
      'score' => Evacob::ScoreModule.new,
      'max' => Evacob::ScoreModule.new,
      'succes' => nil
    },
    'score_niveau2' => {
      'type' => :nombre,
      'parametre' => :N2,
      'score' => Evacob::ScoreModule.new,
      'max' => Evacob::ScoreModule.new,
      'succes' => nil
    },
    'score_niveau3' => {
      'type' => :nombre,
      'parametre' => :N3,
      'score' => Evacob::ScoreModule.new,
      'max' => Evacob::ScoreModule.new,
      'succes' => nil
    },
  }.freeze

  def initialize(campagne, evenements)
    evenements = evenements.map { |e| EvenementEvacob.new e }
    super
  end

  METRIQUES.each_key do |metrique|
    define_method metrique do
    metrique = METRIQUES[metrique]
      metrique['score'].calcule(evenements, metrique['parametre'])
      metrique['max'].calcule_max(evenements, metrique['parametre'])
      metrique['succes'] = calcule_pourcentage_reussite(metrique['score'], metrique['max'])
    end
  end

  private

  def calcule_pourcentage_reussite(score, score_max)
    score / score_max * 100
  end
```

- Récupérer le niveau de la numératie
```ruby
  def niveau_numeratie
    if METRIQUES['score_niveau2']['succes'].blank?
      1
    elsif METRIQUES['score_niveau3']['succes'].blank?
      2
    elsif METRIQUES['score_niveau3']['succes'] < 70
      3
    elsif METRIQUES['score_niveau3']['succes'] > 70
      3
    end
  end
```

- Rajouter les nouveaux profils numératie dans le fichier `/restitution/competence/profil_evacob.rb`

```ruby
  SEUILS = {
    'profil_numeratie' => {
      ::Competence::PROFIL_4 => 4,
      ::Competence::PROFIL_3 => 3,
      ::Competence::PROFIL_2 => 2,
      ::Competence::PROFIL_1 => 1
    },
  }.freeze
```

```ruby
  def profil_numeratie
    return ::Competence::NIVEAU_INDETERMINE if @restitution.abandon?

    @score ||= @restitution.partie.metriques[@metrique]
    return ::Competence::NIVEAU_INDETERMINE if @score.blank?

    SEUILS[@metrique].each do |profil, niveau|
      return profil if @niveau == niveau
    end
  end
```

- Ajouter une méthode `profil_numeratie` dans `/restitution/place_du_marche.rb`

```ruby
def profil_numeratie
  Competence::ProfilEvacob.new(self, 'profil_numeratie', niveau_numeratie)
end
```

- Rendre la partial 'lettrisme' générique pour pouvoir la réutiliser pour le profil numératie en plus du profil littératie

- Modifier le html de `_restitution_globale.arb` pour rajouter le nouveau profil

```html
  if campagne_avec_numeratie?
    div id: 'numeratie', class: 'page page-lettrisme' do
      render 'entete_page', restitution_globale: restitution_globale

      if pdf
        h2 t('titre', scope: 'admin.restitutions.numeratie'), class: 'text-center fr-mt-12v fr-mb-6v'
      else
        h2 t('titre', scope: 'admin.restitutions.numeratie'),
           class: titre_avec_aide_illettrisme.to_s
      end

      render partial: 'lettrisme',
             locals: {
               synthese: restitution_globale.synthese_positionnement,
               pdf: pdf
             }
      render 'pied_page', pre_pied_page: ReferentielAnlciComponent.new('officiel')
    end
  end
```

- Rajouter les trads en rendre les classes css génériques

- Créer le helper `campagne_avec_numeratie` dans `/admin/evaluation.rb`
```ruby
  def campagne_avec_numeratie?
    @evaluation.campagne.avec_positionnement?
  end
```
--> ne pas oublier de le rajouter au dessus dans
```ruby
  controller do
      helper_method :campagne_avec_numeratie?
  end
```

- Ajouter la méthode `avec_numeratie?` dans le modèle campagne
```ruby
  def avec_numeratie?
    configuration_inclus?(Situation::SITUATIONS_NUMERATIE)
  end
```
- Ajouter `SITUATIONS_NUMERATIE = %w[place_du_marche].freeze` au modèle situation

- Modifier le menu sidebar `menu_sidebar.html.arb` pour inclure l'item numératie et s'assurer que l'ancre fonctionne bien lorsqu'on clique dessus

- Faire apparaître la pastille "illetrisme potentiel" sur une évluation si le profil numératie est le profil 1
- Pour ça, il faut que la méthode `presence_pastille?` renvoie true
```ruby
  def presence_pastille?
    liste_filtree_illettrisme_potentiel = params[:scope] == 'illettrisme_potentiel'
    liste_filtree_illettrisme_potentiel ? false : true
  end
```

Question : D'où vient ce `params[:scope]` ?
