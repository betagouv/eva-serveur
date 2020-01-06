# frozen_string_literal: true

ActiveAdmin.register Evenement do
  config.sort_order = 'created_at_desc'
  belongs_to :campagne

  filter :session_id
  filter :date

  colonnes_evenement = proc do
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

  controller do
    def scoped_collection
      campagne = parent
      sessions_ids_de_la_campagne = Partie.where(evaluations: { campagne: campagne })
                                          .joins(:evaluation).select(:session_id)
      Evenement.where(session_id: sessions_ids_de_la_campagne)
    end

    def csv_filename
      "#{Time.current.to_formatted_s(:number)}-evenements-#{@campagne.code}.csv"
    end
  end
end
