# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  permit_params :campagne_id, :nom, :email, :telephone
  menu priority: 4

  includes :campagne

  config.sort_order = 'created_at_desc'

  filter :nom
  filter :campagne
  filter :created_at

  action_item :pdf_restitution, only: :show do
    link_to('Export PDF', {
              parties_selectionnees: params[:parties_selectionnees],
              format: :pdf
            },
            target: '_blank')
  end

  index download_links: -> { params[:action] == 'show' ? [:pdf] : %i[csv xls] } do
    column :nom
    column :campagne
    column :created_at
    actions
  end

  show do
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: 'show'
  end

  controller do
    helper_method :restitution_globale, :parties, :auto_positionnement, :statistiques

    def show
      show! do |format|
        format.html
        format.pdf { render pdf: resource.nom }
      end
    end

    def destroy
      destroy!(location: admin_campagne_path(resource.campagne))
    end

    private

    def statistiques
      @statistiques ||= StatistiquesEvaluation.new(resource)
    end

    def restitution_globale
      @restitution_globale ||=
        FabriqueRestitution.restitution_globale(resource, params[:parties_selectionnees])
    end

    def auto_positionnement
      restitution_globale.restitutions.select do |restitution|
        restitution.situation.nom_technique == Restitution::Bienvenue::NOM_TECHNIQUE
      end.last
    end

    def parties
      Partie.where(evaluation_id: resource).order(:created_at)
    end
  end
end
