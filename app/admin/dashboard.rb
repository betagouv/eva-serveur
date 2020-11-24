# frozen_string_literal: true

ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    campagnes = if current_compte.administrateur?
                  Campagne.all
                else
                  Campagne.where(compte: current_compte)
                end

    evaluations = Evaluation.where(campagne: campagnes).order(created_at: :desc).limit(10)
    contacts = Contact.where(saisi_par: current_compte)
    derniere_actualite = Actualite.order(created_at: :desc).first

    render partial: 'dashboard',
           locals: {
             evaluations: evaluations,
             contacts: contacts,
             derniere_actualite: derniere_actualite
           }
  end
end
