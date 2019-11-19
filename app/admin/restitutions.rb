# frozen_string_literal: true

ActiveAdmin.register Evenement, as: 'Restitutions' do
  menu false
  actions :show, :destroy

  controller do
    helper_method :chemin_vue

    def find_resource
      FabriqueRestitution.depuis_session_id params[:id]
    end

    def chemin_vue
      resource.class.to_s.underscore.tr('/', '_')
    end

    def destroy
      evaluation = resource.evaluation
      resource.supprimer
      redirect_to admin_evaluation_path(evaluation)
    end
  end

  index do
    selectable_column
    column :situation
    column :session_id
    column :date
    column '' do |evenement|
      span link_to t('.rapport'), admin_restitution_path(id: evenement)
      if can? :manage, Compte
        span link_to t('.evenements'),
                     admin_evenements_path(q: { 'session_id_equals' => evenement.session_id })
      end
    end
  end

  show title: :session_id do
    render chemin_vue, restitution: resource
    render 'restitution_competences', restitution: resource
  end

  sidebar :informations_generales, only: :show
end
