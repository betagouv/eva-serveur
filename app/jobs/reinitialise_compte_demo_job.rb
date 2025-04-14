# frozen_string_literal: true

class ReinitialiseCompteDemoJob < ApplicationJob
  include StructureHelper
  queue_as :default

  def perform
    logger.info "création de la structure de démo si nécessaire"
    structure_demo = cree_structure_demo

    logger.info "Recherche et nettoyage d'un compte de démo existant"
    compte_demo = Compte.find_by(email: Eva::EMAIL_DEMO)
    ActiveRecord::Base.transaction { vide_compte compte_demo } if compte_demo.present?

    logger.info "S'assure qu'il y a un compte admin dans la structure de démo"
    ActiveRecord::Base.transaction { verifie_ou_cree_admin structure_demo }

    logger.info "Création d'un compte de démo vierge"
    cree_compte_demo_vierge structure_demo
  end

  private

  def verifie_ou_cree_admin(structure)
    Compte.where(role: :admin, structure: structure).first_or_create do |c|
      logger.info "Création du compte Admin de la structure de démo"
      c.prenom = "Alex"
      c.nom = "Admin"
      c.email = "admin@eva.beta.gouv.fr"
      c.statut_validation = :acceptee
      c.confirmed_at = Time.zone.now
      c.email_bienvenue_envoye = true
      c.password = SecureRandom.uuid
    end
  end

  def cree_compte_demo_vierge(structure_demo)
    Compte.transaction do
      Compte.where(email: Eva::EMAIL_DEMO).first_or_create do |c|
        assigne_champs_compte_demo c
        c.structure = structure_demo
      end
    end
  end

  def assigne_champs_compte_demo(compte)
    compte.prenom = "Dominique"
    compte.nom = "Démo"
    compte.role = :conseiller
    compte.statut_validation = :acceptee
    compte.confirmed_at = Time.zone.now
    compte.cgu_acceptees = true
    compte.email_bienvenue_envoye = true
    compte.password = SecureRandom.uuid
  end
end
