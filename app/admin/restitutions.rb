# frozen_string_literal: true

ActiveAdmin.register Evenement, as: 'Restitutions' do
  menu false
  actions :show, :destroy

  controller do
    helper_method :chemin_vue

    def find_resource
      FabriqueRestitution.depuis_evenement_id params[:id]
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

  show title: :session_id do
    render chemin_vue, restitution: resource
    render 'restitution_competences', restitution: resource
  end

  sidebar :informations_generales, only: :show
end
