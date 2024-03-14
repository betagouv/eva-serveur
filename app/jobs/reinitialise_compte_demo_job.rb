# frozen_string_literal: true

class ReinitialiseCompteDemoJob < ApplicationJob
  queue_as :default

  def perform
    logger.info 'création de la structure si nécessaire'
    structure_demo = cree_structure_demo

    logger.info "Recherche et nettoyage d'un compte de démo existant"
    compte_demo = Compte.find_by(email: Eva::EMAIL_DEMO)
    vide_compte compte_demo if compte_demo.present?

    logger.info "S'assure qu'il y a un compte admin dans cette structure"
    verifie_ou_cree_admin structure_demo

    logger.info "Création d'un compte de démo vierge"
    cree_compte_demo_vierge structure_demo
  end

  private

  def cree_structure_demo
    StructureLocale.where(nom: Eva::STRUCTURE_DEMO).first_or_create do |s|
      s.type_structure = :autre
      s.code_postal = '69003'
    end
  end

  def vide_compte(compte)
    Campagne.where(compte: compte).find_each do |campagne|
      logger.info "destruction de la campagne #{campagne.libelle}"
      Evaluation.where(campagne: campagne).find_each do |evaluation|
        beneficiaire = evaluation.beneficiaire
        evaluation.really_destroy!
        beneficiaire.really_destroy! unless Evaluation.exists?(beneficiaire: beneficiaire)
      end
      campagne.really_destroy!
    end
  end

  def verifie_ou_cree_admin(structure)
    return if Compte.exists?(role: :admin, structure: structure)

    logger.info 'Création du compte Admin'
    Compte.create!(prenom: 'Alex', nom: 'Admin', role: :admin,
                   email: 'admin@eva.beta.gouv.fr',
                   statut_validation: :acceptee,
                   structure: structure, confirmed_at: Time.zone.now,
                   email_bienvenue_envoye: true,
                   password: SecureRandom.uuid)
  end

  def cree_compte_demo_vierge(structure_demo)
    Compte.where(email: Eva::EMAIL_DEMO).first_or_create do |c|
      assigne_champs_compte_demo c
      c.structure = structure_demo
    end
  end

  def assigne_champs_compte_demo(compte)
    compte.prenom = 'Dominique'
    compte.nom = 'Démo'
    compte.role = :conseiller
    compte.statut_validation = :acceptee
    compte.confirmed_at = Time.zone.now
    compte.cgu_acceptees = true
    compte.email_bienvenue_envoye = true
    compte.password = SecureRandom.uuid
  end
end
