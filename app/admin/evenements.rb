ActiveAdmin.register Evenement do
  config.sort_order = "date_desc"
  belongs_to :campagne
  includes partie: %i[situation evaluation]

  filter :partie_situation_nom_technique, label: "Situation",
                                          as: :select,
                                          collection: proc { Situation.pluck(:nom_technique) }
  filter :nom
  filter :donnees, as: :string
  filter :position
  filter :date

  index download_links: false, dsfr_table: proc { true }, class: "fr-table--multiline" do
    column(:evaluation) { |e| e.evaluation.display_name }
    column(:situation) { |e| e.situation.display_name }
    column(:partie) { |e| auto_link(e.partie) }
    column :nom
    column(:donnees) { |e| content_tag(:pre, JSON.pretty_generate(e.donnees)) }
    column :position
    column(:date)
    column(:created_at)
    actions
  end

  controller do
    def scoped_collection
      campagne = parent
      sessions_ids_de_la_campagne = Partie.where(evaluations: { campagne: campagne })
                                          .joins(:evaluation).select(:session_id)
      Evenement.where(session_id: sessions_ids_de_la_campagne)
    end
  end
end
