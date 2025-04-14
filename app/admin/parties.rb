# frozen_string_literal: true

ActiveAdmin.register Partie do
  belongs_to :situation
  includes evaluation: :campagne

  actions :index, :show

  config.sort_order = "created_at_desc"

  scope :all, default: true, show_count: false
  scope(:terminees, show_count: false) do |scope|
    scope.where(session_id: session_ids_des_evenements_fin)
  end
  scope(:non_terminees, show_count: false) do |scope|
    scope.where.not(session_id: session_ids_des_evenements_fin)
  end

  filter :evaluation_id,
         as: :search_select_filter,
         url: proc { admin_evaluations_path },
         fields: %i[nom email telephone],
         display_name: "nom",
         minimum_input_length: 2,
         order_by: "nom_asc"
  filter :session_id
  filter :created_at

  index pagination_total: false do
    column :evaluation
    column :metriques
    column :created_at
    actions do |partie|
      link_to t(".evenements"),
              admin_campagne_evenements_path(
                partie.campagne,
                q: { session_id_eq: partie.session_id }
              )
    end
  end

  controller do
    helper_method :session_ids_des_evenements_fin

    def session_ids_des_evenements_fin
      Evenement.where(nom: Restitution::Base::EvenementsHelper::EVENEMENT[:FIN_SITUATION])
               .select(:session_id)
    end

    def scoped_collection
      Partie.where(situation_id: params[:situation_id])
    end
  end
end
