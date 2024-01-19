# frozen_string_literal: true

COMPTES = {
  'superadmin@beta.gouv.fr' => { prenom: 'super', nom: 'admin', role: 'superadmin' },
  'admin@beta.gouv.fr' => { prenom: 'admin', nom: 'admin', role: 'admin' },
  'conseiller@beta.gouv.fr' => { prenom: 'conseiller', nom: 'conseiller', role: 'conseiller' }
}.freeze

namespace :reviewapp do
  def cree_les_comptes(structure_eva)
    COMPTES.each do |email, data|
      Compte.where(email: email).first_or_create do |compte|
        compte.prenom = data[:prenom]
        compte.nom = data[:nom]
        compte.role = data[:role]
        compte.statut_validation = 'acceptee'
        compte.structure = structure_eva
        compte.password = 'bidon123456'
      end
    end
  end

  def configure_questionnaire(campagne, nom_technique)
    q = Questionnaire.find_by(nom_technique: nom_technique)
    premiere_situation_configuration = campagne.situations_configurations.first
    premiere_situation_configuration.situation = Situation.find_by(nom_technique: 'bienvenue')
    premiere_situation_configuration.questionnaire = q
    premiere_situation_configuration.save
  end

  def cree_campagne(code, libelle, questionnaire)
    campagne = Campagne.find_or_create_by(code: code,
                                          libelle: libelle) do |c|
      c.compte = Compte.find_by(email: 'superadmin@beta.gouv.fr')
      c.parcours_type = ParcoursType.find_by(nom_technique: 'competences_de_base')
      c.type_programme = 'test'
    end
    configure_questionnaire(campagne, questionnaire)
  end

  def cree_campagnes_socio
    cree_campagne('SOCIOAUTO',
                  'sociodémographie et autopositionnement',
                  'sociodemographique_autopositionnement')
    cree_campagne('SOCIO',
                  'sociodémographie',
                  'sociodemographique')
  end

  desc 'init db'
  task initdb: :environment do
    contenu = File.read('db/evaluations_tests.sql')
    requettes = contenu.split(/;$/)
    requettes.pop ## retire la dernière requette qui est vide
    ActiveRecord::Base.transaction do
      requettes.each do |requette|
        ActiveRecord::Base.connection.execute(requette)
      end
    end
  end

  desc 'initialise les données pour les applications de revues'
  task seed: :environment do
    structure_eva = Structure.find_by(nom: 'eva')
    cree_les_comptes structure_eva
    cree_campagnes_socio

    Compte.find_each do |compte|
      compte.encrypted_password = '$2a$11$TE.U8c5Rka9PqDk5uL31xePkHnlp0EYsY7RuDyuhJEODObxoNGq/y'
      compte.save!(validate: false)
    end
  end
end
