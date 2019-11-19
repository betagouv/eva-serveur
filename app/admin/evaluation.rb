# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  filter :campagne, collection: proc { evaluations_visibles }
  filter :created_at
  config.sort_order = 'created_at_desc'
  includes :campagne

  index do
    column :nom
    column :campagne
    column :created_at
    actions
  end

  action_item :pdf, only: :show do
    link_to('Export PDF', {
              parties_selectionnees: params[:parties_selectionnees],
              format: :pdf
            },
            target: '_blank')
  end

  show do
    default_main_content
    params[:parties_selectionnees] =
      FabriqueRestitution.initialise_selection(resource,
                                               params[:parties_selectionnees])
    render partial: 'show'
  end

  controller do
    helper_method :evaluations_visibles, :restitution_globale

    def show
      show! do |format|
        format.html
        format.pdf { render pdf: resource.nom }
      end
    end

    private

    def evaluations_visibles
      current_compte.administrateur? ? Campagne.all : Campagne.where(compte: current_compte)
    end

    def restitution_globale
      FabriqueRestitution.restitution_globale(resource, params[:parties_selectionnees])
    end
  end
end
