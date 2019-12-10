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
      resource.supprimer
      redirect_to admin_evaluation_path(evaluation)
    end
  end

  show do
    render chemin_vue,
           restitution: resource,
           moyenne_glissante: OpenStruct.new(resource.partie.moyenne_metriques),
           ecart_type_glissant: OpenStruct.new(resource.partie.ecart_type_metriques),
           cote_z: OpenStruct.new(resource.partie.cote_z_metriques)
    render 'restitution_competences', restitution: resource
  end

  sidebar :informations_generales, only: :show
end
