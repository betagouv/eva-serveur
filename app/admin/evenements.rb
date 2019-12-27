# frozen_string_literal: true

ActiveAdmin.register Evenement do
  menu if: proc { can? :manage, Compte }
  config.sort_order = 'created_at_desc'

  filter :session_id
  filter :date

  colonnes_evenement = proc do
    column(:campagne) { |e| Partie.find_by(session_id: e.session_id).evaluation.campagne.code }
    column(:situation) { |e| Partie.find_by(session_id: e.session_id).situation.libelle }
    column(:nom_evalue) { |e| Partie.find_by(session_id: e.session_id).evaluation.nom }
    column :session_id
    column :nom
    column :donnees
    column(:date) { |d| l(d.date, format: :date_heure) }
    column(:created_at) { |c_a| l(c_a.created_at, format: :date_heure) }
    column(:updated_at) { |u_a| l(u_a.updated_at, format: :date_heure) }
  end

  index do
    selectable_column
    instance_eval(&colonnes_evenement)
    actions
  end

  csv do
    instance_eval(&colonnes_evenement)
  end
end
