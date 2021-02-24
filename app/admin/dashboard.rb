# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    evaluations = Evaluation.accessible_by(current_ability).order(created_at: :desc).limit(10)
    contacts = Contact.where(saisi_par: current_compte)
    actualites = Actualite.order(created_at: :desc).first(4)

    render partial: 'dashboard',
           locals: {
             evaluations: evaluations,
             contacts: contacts,
             actualites: actualites
           }
  end

  controller do
    before_action do
      annonce = AnnonceGenerale.order(created_at: :desc).where(afficher: true).first
      flash.now[:annonce_generale] = "<span>#{annonce.texte}</span>".html_safe unless annonce.blank?
    end
  end
end
