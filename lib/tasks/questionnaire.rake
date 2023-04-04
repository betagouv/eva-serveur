# frozen_string_literal: true

QUESTIONS_AUTO = %w[
  concentration
  comprehension
  differencier_objets
  analyse_travail
  tache_longue_et_difficile
  travail_sans_erreur
  dangers
  vue
  entendre
  trouble_dys
].freeze

namespace :questionnaire do
  desc 'Complete le questionnaire sociodémographique avec les questions de l autopositionnement'
  task complete_sociodemographique_autopositionnement: :environment do
    logger = RakeLogger.logger

    questions_auto = recupere_questions_auto

    questions_socio =
      Questionnaire.find_by(nom_technique: 'sociodemographique')
                   .questions

    difficultes_informatique = QuestionQcm.find_by(nom_technique: 'difficultes_informatique')

    questionnaire_socio_auto =
      Questionnaire.find_or_initialize_by(nom_technique: 'sociodemographique_autopositionnement')
    questionnaire_socio_auto.libelle = 'Sociodémographique et autopositionnement'
    questionnaire_socio_auto.questions =
      (questions_socio + questions_auto[0...-1]) << difficultes_informatique << questions_auto[-1]
    questionnaire_socio_auto.save

    puts "Nombre questions: #{questionnaire_socio_auto.questions.count}"
    logger.info "c'est fini"
  end
end

def recupere_questions_auto
  Questionnaire.find_by(nom_technique: 'autopositionnement')
               .questions
               .where(nom_technique: QUESTIONS_AUTO)
end
