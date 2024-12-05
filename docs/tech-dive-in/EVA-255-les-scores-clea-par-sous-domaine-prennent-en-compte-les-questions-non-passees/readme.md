<!-- 📄 Standard : https://www.notion.so/captive/Le-cadrage-technique-dbb611e45f114737a6b14745caa584e9?pvs=4 -->
# Les scores Cléa par sous-domaine prennent en compte les questions non passées

> [EVA-255](https://captive-team.atlassian.net/browse/EVA-255)

## Fonctionnement actuel

Lorsqu'on passe les questions du jeu, on envoit des évènements réponses au fur et à mesure avec ces informations. On a accès au reste des questions qui n'ont pas été passé grâce au questionnaire. Cependant, c'est les données du front qui détiennent la métacompétence et le score. Il nous manque ces informations pour calculer le % de réussite en incluant les questions non passées.

## Solution 1 : Récupérer les questions directement depuis le serveur

-> Administrer la métacompétence et le score d'une question dans l'admin. Cela permettrait d'avoir ces informations directement côté serveur. Sachant qu'on a déjà un champ `metacompetence` sur QuestionQcm par ex qui n'est pas utilisé dans la numératie.

1. Ajouter un nouveau champs `score` à Question

2. Rajouter l'enum `:metacompetence` à tous les types de question sauf à QuestionConsigne

3. Ajouter toutes les valeurs de `:metacompetence`
```ruby
  enum :metacompetence, METACOMPETENCES.zip(METACOMPETENCES).to_h
```

4. Migrer les données des questions numératie existantes du parcours normal pour attribuer le `score` et la `metacompetence`

5. Récupère les questions du questionnaires

```ruby
def remplie_la_feuille
  ligne = 1
  evenements_reponses = Evenement.where(session_id: @partie.session_id).reponses
  questions = Questionnaire.find_by(id: @partie.situation.questionnaire).questions
  regroupe_par_code_clea(evenements_reponses, questions).each do |code, evenements|
    ligne = remplis_reponses_par_code(ligne, code, evenements)
  end
  ligne
end
```

6. Les regrouper par code_clea

```ruby
def regroupe_par_code_clea(evenements, questions)
  evenements.group_by(&:code_clea).merge(questions.group_by(&:code_clea)) do |key, evenement_group, question_group|
  evenement_group + question_group
  end
end
```

## Solution 2 : Récupérer les questions du client

-> Envoyer la liste des questions du parcours principal avec leur score et métacompétence au serveur dans un Evenement.

1. Initialiser un nouvel évènement `EvenementQuestion` dans `commun/modeles/evenement_question.js`
```javascript
import Evenement from './evenement';

export default class EvenementQuestion extends Evenement {
  constructor (donnees = {}) {
    super('questions', donnees);
  }
}
```

2. Extraire les questions de la configuration et journaliser un nouvel évènement à envoyer au serveur une fois que la situation place_du_marche démarre.

Dans la vue `place_du_marche/vues/situation.js` :
```javascript
export default class AdaptateurVueSituation extends AdaptateurCommunVueSituation {
  constructor (situation, journal, depotRessources) {
    super(situation, journal, depotRessources, creeStore, PlaceDuMarche, undefined, configurationNormale);
    const questions = recupereQuestions(configurationNormale)
    journal.enregistre(new EvenementQuestions(questions));
    depotRessources.chargeIllustrationsConfigurations([configurationNormale]);
  }
}
```

3. Récupére les évènements questions.

Dans `export_positionnement.rb` :
```ruby
def remplie_la_feuille
  ligne = 1
  evenements = Evenement.where(session_id: @partie.session_id)
  evenements_reponses = evenements.reponses
  questions_repondues = evenements_reponses.pluck(:donnees).map { |donnee| donnee['question'] }
  evenements_questions = evenements.questions.select { |e| !questions_repondues.include?(e[:nom_technique]) }

  evenements = evenements_reponses + evenements_questions
  regroupe_par_code_clea(evenements).each do |code, evenements|
    ligne = remplis_reponses_par_code(ligne, code, evenements)
  end
  ligne
end

def regroupe_par_code_clea(evenements)
  evenements.group_by(&:code_clea)
end
```

Dans `metriques_helper.rb` :
```ruby
EVENEMENT = {
  DEMARRAGE: 'demarrage',
  ACTIVATION_AIDE1: 'activationAide',
  REPONSE: 'reponse',
  QUESTION: 'question'
}.freeze
```

Dans `questions_reponses.rb` :
```ruby
def questions
  @questions ||= @evenements.find_all { |e| e.nom == MetriquesHelper::EVENEMENT[:QUESTION] }.donnees
end
```
