# frozen_string_literal: true

ActiveAdmin.register Evenement, as: 'Evaluations' do
  config.sort_order = 'date_desc'
  actions :index, :show

  batch_action :evaluation_globale_pour do |ids|
    redirect_to admin_evaluation_globale_path(evaluation_ids: ids)
  end

  controller do
    helper_method :chemin_vue

    def scoped_collection
      end_of_association_chain.where(nom: 'demarrage')
    end

    def find_resource
      evenements = Evenement.where(session_id: params[:id]).order(:date)
      situation = evenements.first.situation
      instancie_evaluation situation, evenements
    end

    def instancie_evaluation(situation, evenements)
      classe_evaluation = {
        'inventaire' => Evaluation::Inventaire,
        'controle' => Evaluation::Controle
      }

      classe_evaluation[situation].new(evenements)
    end

    def chemin_vue
      resource.class.to_s.underscore.tr('/', '_')
    end
  end

  index do
    selectable_column
    column :situation
    column :utilisateur
    column :session_id
    column :date
    column '' do |evenement|
      span link_to t('.rapport'), admin_evaluation_path(id: evenement.session_id)
      span link_to t('.evenements'),
                   admin_evenements_path(q: { 'session_id_equals' => evenement.session_id })
    end
  end

  show title: :session_id do
    render chemin_vue, evaluation: resource
    render 'evaluation_competences', evaluation: resource
  end

  sidebar :informations_generales, only: :show
end
