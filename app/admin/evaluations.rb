ActiveAdmin.register Evenement, as: 'Evaluations' do
  config.sort_order = 'date_desc'
  actions :index, :show

  controller do
    def scoped_collection
      end_of_association_chain.where(nom: 'demarrage')
    end

    def find_resource
      EvaluationInventaire.new(
        Evenement.where(session_id: params[:id]).order(:date)
      )
    end
  end

  index do
    column :situation
    column :utilisateur
    column :session_id
    column :date
    column '' do |evenement|
      span link_to t('.rapport'), admin_evaluation_path(id: evenement.session_id)
      span link_to t('.evenements'), admin_evenements_path(q: { 'session_id_equals' => evenement.session_id })
    end
  end

  show title: :session_id do
    render 'evaluation', evaluation: resource
  end

  sidebar :info, only: :show do
    render 'evaluation_sidebar', evaluation: resource
  end
end
