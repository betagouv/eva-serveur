# frozen_string_literal: true

require 'addressable/uri'

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    evaluations = Evaluation.accessible_by(current_ability).order(created_at: :desc).limit(10)
    actualites = Actualite.order(created_at: :desc).first(4)
    campagnes = Campagne.accessible_by(current_ability).order(created_at: :desc).limit(10)

    render partial: 'dashboard',
           locals: {
             evaluations: evaluations,
             actualites: actualites,
             campagnes: campagnes
           }
  end

  controller do
    before_action do
      flash.now[:annonce_generale] = "<span>#{annonce.texte}</span>".html_safe unless annonce.blank?
      if comptes_en_attente? && current_compte.validation_acceptee?
        lien = admin_comptes_url(q: { statut_validation_eq: 'en_attente' })
        flash.now[:comptes_en_attente] =
          "<span>#{t('.info_comptes_en_attente', lien: lien)}</span>".html_safe
      end
      message_incitation_compte_personnel
    end
    before_action :recupere_support

    private

    def annonce
      @annonce ||= AnnonceGenerale.order(created_at: :desc).find_by(afficher: true)
    end

    def comptes_en_attente?
      @comptes_en_attente ||= Compte.where(statut_validation: :en_attente)
                                    .where(structure_id: current_compte.structure_id)
                                    .exists?
    end

    def message_incitation_compte_personnel
      return unless current_compte.compte_generique?

      lien = new_admin_compte_path(compte: { statut_validation: 'acceptee' })
      flash.now[:compte_generique] =
        "<span>#{t('.incitation_creation_compte_personnel', lien: lien)}</span>".html_safe
    end

    def recupere_support
      @support = Compte.find_by(email: Eva::EMAIL_SUPPORT)
    end
  end
end
