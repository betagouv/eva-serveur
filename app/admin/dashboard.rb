# frozen_string_literal: true

require 'addressable/uri'

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    render partial: 'dashboard',
           locals: {
             evaluations: evaluations,
             actualites: actualites,
             campagnes: campagnes
           }
  end

  controller do
    before_action do
      flash.now[:annonce_generale] = "<span>#{annonce.texte}</span>".html_safe if annonce.present?
      message_incitation_compte_personnel
    end

    before_action :recupere_support, :recupere_evaluations, :recupere_actualites,
                  :recupere_campagnes, :recupere_prise_en_main, :comptes_en_attente,
                  :recupere_evaluations_sans_mise_en_action

    def index
      return if params[:ville_ou_code_postal].blank?

      @structures_code_postal = StructureLocale.where(code_postal: params[:code_postal])
      @structures = StructureLocale.near("#{params[:ville_ou_code_postal]}, FRANCE")
                                   .where.not(id: @structures_code_postal)
    end

    private

    def annonce
      @annonce ||= AnnonceGenerale.order(created_at: :desc).find_by(afficher: true)
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

    def recupere_evaluations
      @evaluations = Evaluation.tableau_de_bord(current_ability).limit(10)
    end

    def recupere_evaluations_sans_mise_en_action
      @evaluations_sans_mise_en_action =
        Evaluation.tableau_de_bord_mises_en_action(current_ability).limit(6)
    end

    def recupere_actualites
      @actualites = Actualite.order(created_at: :desc)
                             .includes(illustration_attachment: :blob).first(6)
    end

    def recupere_campagnes
      @campagnes = Campagne.accessible_by(current_ability).order(created_at: :desc).limit(10)
    end

    def recupere_prise_en_main
      @prise_en_main = PriseEnMain.new(
        compte: current_compte,
        nombre_campagnes: @campagnes.size,
        nombre_evaluations: @evaluations.size
      )
    end

    def comptes_en_attente
      @comptes_en_attente = Compte.where(
        statut_validation: :en_attente,
        structure_id: current_compte.structure_id
      )
    end
  end
end
