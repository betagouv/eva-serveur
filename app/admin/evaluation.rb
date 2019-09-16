# frozen_string_literal: true

ActiveAdmin.register Evaluation do
  filter :campagne, collection: proc { evaluations_visibles }
  filter :created_at

  index do
    column :nom
    column :campagne
    column :created_at
    actions
  end

  action_item :pdf, only: :show, if: proc { restitution_globale.present? } do
    link_to('Export PDF', { format: :pdf }, target: '_blank')
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

    def restitution_globale
      restitution_ids = restitutions.pluck(:id)
      return if restitution_ids.blank?

      evaluation = Evenement.find(restitution_ids.first).evaluation
      restitutions = restitution_ids.map do |id|
        FabriqueRestitution.depuis_evenement_id id
      end
      Restitution::Globale.new restitutions: restitutions, evaluation: evaluation
    end
  end
end
