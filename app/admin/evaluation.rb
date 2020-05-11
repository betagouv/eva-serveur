# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  actions :index, :show, :destroy
  belongs_to :campagne

  config.sort_order = 'created_at_desc'

  filter :nom
  filter :created_at

  action_item :pdf_restitution, only: :show do
    link_to('Export PDF', {
              parties_selectionnees: params[:parties_selectionnees],
              format: :pdf
            },
            target: '_blank')
  end

  index download_links: -> { params[:action] == 'show' ? [:pdf] : [:csv] } do
    selectable_column
    column :nom
    column :created_at
    actions
  end

  show do
    default_main_content
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: 'show'
  end

  controller do
    helper_method :restitution_globale, :parties, :auto_positionnement

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

    def restitution_globale
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

    def scoped_collection
      Evaluation.where(campagne: params[:campagne_id])
    end
  end
end
