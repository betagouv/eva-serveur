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
    begin
      render chemin_vue, restitution: resource
    rescue ActionView::MissingTemplate
      nil
    end
    render 'restitution_metriques',
           restitution: resource,
           moyenne_glissante: OpenStruct.new(resource.moyenne_metriques),
           ecart_type_glissant: OpenStruct.new(resource.ecart_type_metriques),
           cote_z: OpenStruct.new(resource.cote_z_metriques)
    render 'restitution_competences_de_base', restitution: resource
    render 'restitution_competences', restitution: resource
  end

  sidebar :informations_generales, only: :show
end
