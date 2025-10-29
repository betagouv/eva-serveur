class CreeQuestionnaireLitteratie < ActiveRecord::Migration[7.0]
  class ::Questionnaire < ApplicationRecord; end
  class ::QuestionnaireQuestion < ApplicationRecord; end
  class ::Question < ApplicationRecord; end
  class ::Transcription < ApplicationRecord; end
  class ::Choix < ApplicationRecord;end

  def up
    litteratie = Questionnaire.find_or_create_by(nom_technique: 'litteratie_2024') do |q|
      q.libelle = "Littératie 2024"
    end
    question = Question.find_or_create_by(nom_technique: 'lodi_1') do |q|
      q.libelle = "LOdi1"
      q.type = 'QuestionQcm'
    end
    Transcription.find_or_create_by(categorie: :intitule, question_id: question.id) do |t|
      t.ecrit = "De quoi s’agit-il ?"
    end
    Transcription.find_or_create_by(categorie: :modalite_reponse, question_id: question.id) do |t|
      t.ecrit = 'Choisissez une des réponses ci-dessous. Pour écouter ou réécouter les questions ou les réponses, cliquez sur le bouton « Lecture » ( <svg width="16" height="16" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><circle cx="10" cy="10" fill="#6e84fe" r="10"/><path d="M14 8.701c1 .577 1 2.02 0 2.598l-5.813 3.356a1.5 1.5 0 0 1-2.25-1.3v-6.71a1.5 1.5 0 0 1 2.25-1.3z" fill="#fff"/></svg> ) à gauche de la phrase que vous souhaitez entendre. Pour confirmer votre réponse, cliquez sur « Valider ».'
    end
    choix = [
      { nom_technique: 'LOdi_couverture', intitule: 'La couverture', type_choix: 'mauvais' },
      { nom_technique: 'LOdi_programme_tele', intitule: 'Un programme télé', type_choix: 'bon' },
      { nom_technique: 'LOdi_mots_croises', intitule: 'Une page de mots croisés', type_choix: 'mauvais' }
    ]
    choix.each do |data|
      Choix.find_or_create_by(nom_technique: data[:nom_technique], question_id: question.id) do |c|
      c.intitule = data[:intitule]
      c.type_choix = data[:type_choix]
      end
    end
    QuestionnaireQuestion.find_or_create_by(questionnaire_id: litteratie.id, question_id: question.id)
  end
end
