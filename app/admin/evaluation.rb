# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  actions :index, :show, :destroy
  belongs_to :campagne

  config.sort_order = 'created_at_desc'

  filter :nom
  filter :created_at

  action_item :pdf, only: :show do
    link_to('Export PDF', {
              parties_selectionnees: params[:parties_selectionnees],
              format: :pdf
            },
            target: '_blank')
  end

  index download_links: %i[csv pdf] do
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
    helper_method :restitution_globale, :parties

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

    def parties
      Partie.where(evaluation_id: resource)
    end
  end
end
