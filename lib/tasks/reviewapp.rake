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
    ParcoursType.update(type_de_programme: 'pre_positionnement')
    ParcoursType
      .find('fa096bb3-5488-402a-838a-521a244c02ca')
      .update(type_de_programme: 'positionnement')

    structure_eva = Structure.where(nom: 'eva').first
    cree_les_comptes structure_eva

    Compte.all.each do |compte|
      compte.encrypted_password = '$2a$11$d.kf40n..7zqTGgCPANFlOiLvwGH35EPh0OsY6euJaje3Us20KIWO'
      compte.save!(validate: false)
    end
  end
end
