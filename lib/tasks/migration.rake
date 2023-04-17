# frozen_string_literal: true

require 'rake_logger'

namespace :migration do
  desc 'Migre les anciennes campagnes à Bienvenu 2023'
  task bienvenue2023: :environment do
    logger = RakeLogger.logger

    questionnaire_socio =
      Questionnaire.find_by nom_technique: Questionnaire::SOCIODEMOGRAPHIQUE
    questionnaire_socio_auto = Questionnaire.bienvenue_avec_autopositionnement
    bienvenue = Situation.find_by nom_technique: Situation::BIENVENUE
    total = Campagne.count
    count = 0
    logger.info "Nombre de campagne : #{total}"
    Campagne.includes(:situations_configurations).find_each do |campagne|
      count += 1
      logger.info "#{count}/#{total} #{campagne.libelle}"

      configure campagne, questionnaire_socio, questionnaire_socio_auto, bienvenue, logger
    end
    bienvenue.update(questionnaire: questionnaire_socio)
    SituationConfiguration.where(situation: bienvenue,
                                 questionnaire: questionnaire_socio).update(questionnaire_id: nil)
    logger.info "C'est fini"
  end

  def configure(campagne, questionnaire_socio, questionnaire_socio_auto, bienvenue, logger)
    situation_configuration = campagne.situations_configurations.find(&:bienvenue?)
    if situation_configuration.present?
      met_a_jour_questionnaire situation_configuration, questionnaire_socio_auto, logger
    else
      position = calcule_position campagne
      campagne.situations_configurations.create situation_id: bienvenue.id,
                                                questionnaire_id: questionnaire_socio.id,
                                                position: position
      logger.info "ajout de bienvenue en position #{position}"
    end
  end

  def met_a_jour_questionnaire(situation_configuration, questionnaire_socio_auto, logger)
    questionnaire = situation_configuration.questionnaire
    unless questionnaire.nil? || questionnaire.nom_technique == Questionnaire::AUTOPOSITIONNEMENT
      return
    end

    situation_configuration.questionnaire = questionnaire_socio_auto
    situation_configuration.save
    logger.info 'mise à jour du questionnaire'
  end

  def calcule_position(campagne)
    premiere_configuration = campagne.situations_configurations.first
    if premiere_configuration.present? &&
       premiere_configuration.situation.nom_technique == Situation::PLAN_DE_LA_VILLE
      return 2
    end

    1
  end
end
