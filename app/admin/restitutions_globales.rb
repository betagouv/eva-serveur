# frozen_string_literal: true

ActiveAdmin.register_page 'Restitution Globale' do
  menu false

  controller do
    helper_method :restitution_globale

    def restitution_globale
      restitutions = params[:restitution_ids].map do |id|
        FabriqueRestitution.depuis_evenement_id id
      end
      Restitution::Globale.new restitutions: restitutions
    end
  end

  content do
    render partial: 'restitution_globale'
  end
end
