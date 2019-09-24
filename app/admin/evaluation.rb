# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  filter :campagne, collection: proc { evaluations_visibles }
  filter :created_at
  config.sort_order = 'created_at_desc'

  index do
    column :nom
    column :campagne
    column :created_at
    actions
  end

  action_item :pdf, only: :show, if: proc { restitution_globale.present? } do
    link_to('Export PDF', {
              restitutions_selectionnees: params[:restitutions_selectionnees],
              format: :pdf
            },
            target: '_blank')
  end

  show do
    default_main_content
    render partial: 'show'
  end

  controller do
    helper_method :evaluations_visibles, :restitutions, :restitution_globale

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

    def restitutions
      Evenement.where(nom: 'demarrage', evaluation_id: params[:id])
    end

    def restitutions_selectionnees_ids
      params[:restitutions_selectionnees] ||= restitutions.collect { |r| r.id.to_s }
      params[:restitutions_selectionnees]
    end

    def restitution_globale
      return if restitutions_selectionnees_ids.blank?

      evaluation = Evenement.find(restitutions_selectionnees_ids.first).evaluation
      restitutions = restitutions_selectionnees_ids.map do |id|
        FabriqueRestitution.depuis_evenement_id id
      end
      Restitution::Globale.new restitutions: restitutions, evaluation: evaluation
    end
  end
end
