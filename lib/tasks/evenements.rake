# frozen_string_literal: true

require 'rake_logger'

noms_techniques = {
  'bienvenue_tout_a_fait_daccord' => 'pas_du_tout_daccord',
  'bienvenue_daccord' => 'pas_daccord',
  'bienvenue_plutot_daccord' => 'plutot_pas_daccord',
  'bienvenue_ni_daccord' => 'ni_daccord_ni_pas_daccord',
  'bienvenue_plutot_pas_daccord' => 'plutot_daccord',
  'bienvenue_pas_daccord' => 'daccord',
  'bienvenue_pas_du_tout_daccord' => 'tout_a_fait_daccord'
}

noms_techniques_audios = {
  'pas_du_tout_daccord' => 'bienvenue_pas_du_tout_daccord',
  'pas_daccord' => 'bienvenue_pas_daccord',
  'plutot_pas_daccord' => 'bienvenue_plutot_pas_daccord',
  'ni_daccord_ni_pas_daccord' => 'bienvenue_ni_daccord',
  'plutot_daccord' => 'bienvenue_plutot_daccord',
  'daccord' => 'bienvenue_daccord',
  'tout_a_fait_daccord' => 'bienvenue_tout_a_fait_daccord'
}

namespace :evenements do
  desc 'met à jour les évènements questions et réponses de la question confondre objets'
  task update_questions_reponses: :environment do
    logger = RakeLogger.logger
    ancienne_question = QuestionQcm.find_by(nom_technique: 'confondre_objets')
    evenements = Evenement.where("donnees->>'question' = '#{ancienne_question.id}'")
    noms_techniques.each do |ancien_nom, nouveau_nom|
      # rubocop:disable Rails/SkipsModelValidations
      evenements.where(requete_json(ancien_nom)).update_all(donnees: json(nouveau_nom))
      # rubocop:enable Rails/SkipsModelValidations
      logger.info "MAJ des réponses '#{ancien_nom}' pour '#{nouveau_nom}' terminée"
    end
    met_a_jour_evenements_affichage(evenements)
    met_a_jour_noms_techniques_choix(nouvelle_question, noms_techniques_audios)

    logger.info "C'est fini"
  end
end

def choix_id(nom_technique)
  Choix.find_by(nom_technique: nom_technique)&.id
end

def nouvelle_question
  QuestionQcm.find_by(nom_technique: 'differencier_objets')
end

def json(nom_technique)
  { question: nouvelle_question.id, reponse: choix_id(nom_technique) }
end

def requete_json(nom_technique)
  "donnees->>'reponse' = '#{choix_id(nom_technique)}'"
end

def met_a_jour_evenements_affichage(evenements)
  # rubocop:disable Rails/SkipsModelValidations
  evenements.where(nom: 'affichageQuestionQCM')
            .update_all(donnees: { question: nouvelle_question.id })
  # rubocop:enable Rails/SkipsModelValidations
end

def met_a_jour_noms_techniques_choix(nouvelle_question, noms_techniques_audios)
  nouvelle_question.choix.each do |choix|
    choix.update(nom_technique: noms_techniques_audios[choix.nom_technique])
  end
end
