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
end
