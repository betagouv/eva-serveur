# frozen_string_literal: true

ActiveAdmin.register_page 'Restitution Globale' do
  menu false

  controller do
    helper_method :restitution_globale

    def restitution_globale
      evaluation = Evenement.find(params[:restitution_ids].first).evaluation
      restitutions = params[:restitution_ids].map do |id|
        FabriqueRestitution.depuis_evenement_id id
      end
      Restitution::Globale.new restitutions: restitutions, evaluation: evaluation
    end
  end

  content do
    render partial: 'restitution_globale'
  end
end
