# frozen_string_literal: true

ActiveAdmin.register Partie, as: 'Restitutions' do
  menu false
  actions :show, :destroy

  controller do
    helper_method :chemin_vue

    def find_resource
      FabriqueRestitution.instancie params[:id]
    end

    def chemin_vue
      resource.class.to_s.underscore.tr('/', '_')
    end

    def destroy
      evaluation = resource.evaluation
      campagne = resource.campagne
      resource.supprimer
      redirect_to admin_campagne_evaluation_path(campagne, evaluation)
    end
  end

  show do
    render chemin_vue, restitution: resource
    render 'restitution_competences', restitution: resource
  end

  sidebar :informations_generales, only: :show
end
