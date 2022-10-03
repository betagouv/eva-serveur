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
    ParcoursType.find_or_create_by(nom_technique: 'litteratie_evacob') do |parcours_type|
      parcours_type.libelle = 'Parcours « compétences langagières (écrit) - ex-Evacob »'
      parcours_type.duree_moyenne = '30 minutes'
      parcours_type.categorie = 'evaluation_avancee'
      parcours_type.description = %(Ce parcours permet une évaluation fine des compétences\
langagières en matière d’écrit : lecture, identification et signalement de mots,\
compréhension de texte et écriture de mots.)
      situations = Situation.where(nom_technique: ['cafe_de_la_place'])
      parcours_type.situations_configurations_attributes =
        situations.map.with_index do |situation, index|
          { situation_id: situation.id, position: index }
        end
    end

    structure_eva = Structure.where(nom: 'eva').first
    cree_les_comptes structure_eva

    Compte.all.each do |compte|
      compte.encrypted_password = '$2a$11$d.kf40n..7zqTGgCPANFlOiLvwGH35EPh0OsY6euJaje3Us20KIWO'
      compte.save!(validate: false)
    end
  end
end
