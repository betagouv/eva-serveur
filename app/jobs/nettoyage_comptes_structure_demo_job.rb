# frozen_string_literal: true

class NettoyageComptesStructureDemoJob < ApplicationJob
  include StructureHelper
  queue_as :default

  def perform
    logger.info "création de la structure de démo si nécessaire"
    structure_demo = cree_structure_demo

    logger.info "Recherche et nettoyage des comptes en attente existants"
    Compte.where(structure: structure_demo, statut_validation: :en_attente).find_each do |compte|
      next if compte.email == Eva::EMAIL_DEMO_EN_ATTENTE

      ActiveRecord::Base.transaction { vide_compte compte }
      compte.really_destroy!
    end
  end
end
