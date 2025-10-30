ActiveAdmin.register Evenement do
  config.sort_order = "date_desc"
  belongs_to :campagne
  includes partie: %i[situation evaluation]

  filter :partie_situation_nom_technique, label: "Situation",
                                          as: :select,
                                          collection: proc { Situation.pluck(:nom_technique) }
  filter :nom
  filter :date

  colonnes_evenement = proc do
    column(:evaluation) { |e| e.evaluation.display_name }
    column(:situation) { |e| e.situation.display_name }
    column(:partie) { |e| auto_link(e.partie) }
    column :nom
    column :donnees
    column :position
    column(:date)
    column(:created_at)
  end

  index do
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
      "#{Time.current.to_fs(:number)}-evenements-#{@campagne.code}.csv"
    end
  end
end
