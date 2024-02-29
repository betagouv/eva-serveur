# frozen_string_literal: true

require 'rake_logger'

namespace :migration_donnees do
  desc 'initialise les categories des questions'
  task initialise_categorie_questions: :environment do
    logger = RakeLogger.logger

    questions = {
      'age' => { categorie: :situation, libelle: 'Âge' },
      'genre' => { categorie: :situation, libelle: 'Genre' },
      'langue_maternelle' => { categorie: :situation, libelle: 'Français langue maternelle' },
      'derniere_situation' => { categorie: :situation, libelle: 'Dernière situation' },
      'lieu_scolarite' => { categorie: :scolarite, libelle: 'Lieu de scolarité' },
      'dernier_niveau_etude' => { categorie: :scolarite, libelle: "niveau d'étude" },
      'bienvenue_12' => { categorie: :appareils, libelle: 'écrans' },
      'bienvenue_13' => { categorie: :appareils, libelle: 'ordinateur' },
      'bienvenue_14' => { categorie: :appareils, libelle: 'tablette' },
      'difficultes_informatique' => { categorie: :appareils,
                                      libelle: "Difficultés avec l'informatique" },
      'vue' => { categorie: :sante, libelle: 'Vue' },
      'bienvenue_9' => { categorie: :sante, libelle: 'Couleur' },
      'entendre' => { categorie: :sante, libelle: 'Audition' },
      'bienvenue_11' => { categorie: :sante, libelle: 'Concentration' },
      'trouble_dys' => { categorie: :sante, libelle: 'Troubles dys' }
    }
    questions.each do |nom_technique, champs|
      Question.find_by(nom_technique: nom_technique).update(champs)
      valeurs = Question.where(nom_technique: nom_technique).pluck(*champs.keys)
      logger.info "#{nom_technique} : #{valeurs}"
    end
    logger.info "C'est fini"
  end

  def detruit_compte(compte, logger)
    Campagne.where(compte: compte).find_each do |campagne|
      logger.info "destruction de la campagne #{campagne.libelle}"
      Evaluation.where(campagne: campagne).find_each(&:really_destroy!)
      campagne.really_destroy!
    end
    logger.info "destruction du compte #{compte.email}"
    compte.really_destroy!
  end

  def verifie_ou_cree_admin(structure, logger)
    return if Compte.exists?(role: :admin, structure: structure)

    logger.info 'Création du compte Admin'
    Compte.create!(prenom: 'Alex', nom: 'Admin', role: :admin,
                   email: 'admin@eva.beta.gouv.fr',
                   statut_validation: :acceptee,
                   structure: structure, confirmed_at: Time.zone.now,
                   email_bienvenue_envoye: true,
                   password: SecureRandom.uuid)
  end

  desc '(re-)initialise le compte de démo'
  task reinit_compte_demo: :environment do
    logger = RakeLogger.logger
    logger.info 'création de la structure si nécessaire'
    structure_demo = StructureLocale.where(nom: 'Structure démo ANLCI').first_or_create do |s|
      s.type_structure = :autre
      s.code_postal = '69003'
    end

    logger.info "Recherche et suppression d'un compte de démo existant"
    compte_demo = Compte.find_by(email: Eva::EMAIL_DEMO)
    detruit_compte compte_demo, logger if compte_demo.present?

    logger.info "S'assure qu'il y a un compte admin dans cette structure"
    verifie_ou_cree_admin structure_demo, logger

    logger.info "Création d'un compte de démo vierge"
    Compte.create!(prenom: 'Dominique',
                   nom: 'Démo',
                   email: Eva::EMAIL_DEMO,
                   role: :conseiller,
                   statut_validation: :acceptee,
                   structure: structure_demo,
                   confirmed_at: Time.zone.now,
                   cgu_acceptees: true,
                   email_bienvenue_envoye: true,
                   password: SecureRandom.uuid)
  end
end
