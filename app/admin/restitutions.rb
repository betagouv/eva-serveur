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
    begin
      render chemin_vue, restitution: resource
    rescue ActionView::MissingTemplate
      nil
    end
    render 'restitution_metriques',
           metriques_partie: resource.partie.metriques,
           moyenne: OpenStruct.new(resource.moyennes_metriques),
           ecart_type: OpenStruct.new(resource.ecarts_types_metriques),
           cote_z: OpenStruct.new(resource.cote_z_metriques)
    render 'restitution_competences_de_base', restitution: resource
    render 'restitution_competences', restitution: resource
  end

  sidebar :informations_generales, only: :show
end
