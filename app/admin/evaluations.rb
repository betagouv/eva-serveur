# frozen_string_literal: true

ActiveAdmin.register Evenement, as: 'Evaluations' do
  config.sort_order = 'date_desc'
  actions :index, :show

  batch_action :evaluation_globale_pour, priority: 1 do |ids|
    redirect_to admin_evaluation_globale_path(evaluation_ids: ids)
  end

  batch_action :destroy, confirm: I18n.t('active_admin.evaluations.confirme_suppression') do |ids|
    ids.each do |id|
      FabriqueEvaluation.depuis_evenement_id(id).supprimer
    end
    redirect_to collection_path,
                alert: I18n.t('active_admin.evaluations.supprimees', count: ids.size)
  end

  controller do
    helper_method :chemin_vue

    def scoped_collection
      end_of_association_chain.where(nom: 'demarrage')
    end

    def find_resource
      FabriqueEvaluation.depuis_evenement_id params[:id]
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
      span link_to t('.rapport'), admin_evaluation_path(id: evenement)
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
