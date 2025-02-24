# EVA 342 : Le score cléa ne doit pas prendre en compte les questions de rattrapage de niveau 3 que je n'ai pas passé


## Où ça se passe ?

Dans le model: `EvenementQuestion`
on a la méthode 
```ruby
  def self.prises_en_compte_pour_calcul_score_clea(evenements_questions) # rubocop:disable all
    resultat = evenements_questions.flatten

    evenements_questions_groupes = evenements_questions.group_by do |evenement_question|
      evenement_question.nom_technique[0, 5]
    end

    evenements_questions_groupes.each do |nom_technique, groupe|
      next unless groupe.all? do |evenement_question|
        evenement_question.est_principale? && evenement_question.score.positive?
      end

      nom_technique_rattrapage =
        Restitution::Evacob::ScoreModule::NUMERATIE_METRIQUES[nom_technique]

      next unless nom_technique_rattrapage

      resultat.reject! do |evenement_question|
        evenement_question.nom_technique.start_with? nom_technique_rattrapage
      end
    end


    resultat
  end
```

Dans `place_du_marche.rb` :
on initialise avec:
`evenements_reponses = evenements.select { |evenement| evenement.nom == 'reponse' }`
et après on fait:
```ruby
@evenements_questions = questions_situation.map do |question_situation|
        evenement = evenements_reponses.find do |e|
          e.question_nom_technique == question_situation.nom_technique
        end
        EvenementQuestion.new(question: question_situation, evenement: evenement)
      end
@evenements_questions_a_prendre_en_compte =
    EvenementQuestion.prises_en_compte_pour_calcul_score_clea(@evenements_questions)
```

On fait la même chose dans `export_numeratie.rb`


/!\Je pense qu'il va falloir ici clarifier les évènements passés des évènements non passés./!\

Exemple à prendre pour écrire les tests:
Si je suis sorti au niveau 2, les niveaux 3 ne devraient pas resortir


Quid du front? est-ce qu'on va rajouter cette logique dans le front? sachant que pour l'instant, on a cette logique `evenement_question` uniquement back.

