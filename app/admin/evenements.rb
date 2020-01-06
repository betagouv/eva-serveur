# frozen_string_literal: true

ActiveAdmin.register Evenement do
  config.sort_order = 'date_desc'
  belongs_to :campagne
  includes partie: %i[situation evaluation]

  filter :partie, collection: proc { Partie.pluck(:session_id) }
  filter :date

  colonnes_evenement = proc do
    column(:evaluation) { |e| e.evaluation.display_name }
    column(:situation) { |e| e.situation.display_name }
    column(:partie) { |e| e.partie.display_name }
    column :nom
    column :donnees
    column(:date) { |e| l(e.date, format: :date_heure) }
    column(:created_at) { |e| l(e.created_at, format: :date_heure) }
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
      sessions_ids_de_la_campagne = Partie.where(evaluation: campagne.evaluations)
                                          .select(:session_id)
      Evenement.where(session_id: sessions_ids_de_la_campagne)
    end

    def csv_filename
      "#{Time.current.to_formatted_s(:number)}-evenements-#{@campagne.code}.csv"
    end
  end
end
