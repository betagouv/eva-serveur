class CreeQuestionGlisserDeposerCafe < ActiveRecord::Migration[7.0]
  class ::Questionnaire < ApplicationRecord; end
  class ::QuestionnaireQuestion < ApplicationRecord; end
  class ::Question < ApplicationRecord; end
  class ::Transcription < ApplicationRecord; end
  class ::Choix < ApplicationRecord;end

  def up
    litteratie = Questionnaire.find_or_create_by(nom_technique: 'litteratie_2024') do |q|
      q.libelle = "Littératie 2024"
    end
    question = Question.find_or_create_by(nom_technique: 'hpar_1') do |q|
      q.libelle = "HPar1"
      q.type = 'QuestionGlisserDeposer'
      q.description = 'Vous avez placé tous les blocs de texte !\nVous pouvez toujours modifier leur ordre directement dans la page du journal.'
    end
    Transcription.find_or_create_by(categorie: :intitule, question_id: question.id) do |t|
      t.ecrit = "Si l’ordre vous convient, cliquez sur « Valider »."
    end
    choix = [
    {
      nom_technique: 'hpar_1R1',
      position: 7,
      position_client: 1,
      intitule: "Durant leur séjour à l'hôpital, ils auront tout loisir de se raconter leurs petites histoires..."
    }, {
      nom_technique: 'hpar_1R2',
      position: 2,
      position_client: 2,
      intitule: "En effet, il est 8 h 45 quand le jeune David G. s'apprête à traverser la chaussée."
    }, {
      nom_technique: 'hpar_1R3',
      position: 3,
      position_client: 3,
      intitule: "Un de ses copains de classe, Rémi P. qui était déjà devant l'école, se met lui aussi à traverser la chaussée pour aller à sa rencontre."
    }, {
      nom_technique: 'hpar_1R4',
      position: 6,
      position_client: 4,
      intitule: "Les deux amis, blessés au visage pour l'un et à la jambe pour l'autre, ont été transportés à l'hôpital tout proche."
    }, {
      nom_technique: 'hpar_1R5',
      position: 4,
      position_client: 5,
      intitule: "Les deux garçons se dirigent l'un vers l'autre sans regarder la circulation."
    }, {
      nom_technique: 'hpar_1R6',
      position: 1,
      position_client: 6,
      intitule: "Ce matin, alors que les enfants arrivaient à proximité de l'école, deux garçons particulièrement distraits ont provoqué un accident sur la voie publique près de l'école Jules Ferry."
    }, {
      nom_technique: 'hpar_1R7',
      position: 5,
      position_client: 7,
      intitule: "Deux voitures qui arrivaient en sens contraire, ont chacune projeté violemment un garçon à terre provoquant la frayeur des témoins."
    }
  ]
    choix.each do |data|
      Choix.find_or_create_by(nom_technique: data[:nom_technique], question_id: question.id) do |c|
      c.position = data[:position]
      c.position_client = data[:position_client]
      c.intitule = data[:intitule]
      c.type_choix = 'bon'
      end
    end
    QuestionnaireQuestion.find_or_create_by(questionnaire_id: litteratie.id, question_id: question.id)
  end
end
