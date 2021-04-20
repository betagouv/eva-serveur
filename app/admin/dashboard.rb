# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    evaluations = Evaluation.accessible_by(current_ability).order(created_at: :desc).limit(10)
    actualites = Actualite.order(created_at: :desc).first(4)

    render partial: 'dashboard',
           locals: {
             evaluations: evaluations,
             actualites: actualites
           }
  end

  controller do
    before_action do
      flash.now[:annonce_generale] = "<span>#{annonce.texte}</span>".html_safe unless annonce.blank?
      if comptes_en_attente?
        lien = admin_comptes_url(q: { statut_validation_eq: 'en_attente' })
        flash.now[:comptes_en_attente] =
          "<span>#{t('.info_comptes_en_attente', lien: lien)}</span>".html_safe
      end
    end

    private

    def annonce
      @annonce ||= AnnonceGenerale.order(created_at: :desc).find_by(afficher: true)
    end

    def comptes_en_attente?
      @comptes_en_attente ||= Compte.where(statut_validation: :en_attente)
                                    .where(structure_id: current_compte.structure_id)
                                    .exists?
    end
  end
end
