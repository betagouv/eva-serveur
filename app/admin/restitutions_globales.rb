# frozen_string_literal: true

ActiveAdmin.register_page 'Restitution Globale' do
  menu false

  action_item :telecharger do
    link_to 'Exporter en PDF', lien_pdf, target: '_blank'
  end

  controller do
    helper_method :restitution_globale, :lien_pdf

    def restitution_globale
      evaluation = Evenement.find(params[:restitution_ids].first).evaluation
      restitutions = params[:restitution_ids].map do |id|
        FabriqueRestitution.depuis_evenement_id id
      end
      Restitution::Globale.new restitutions: restitutions, evaluation: evaluation
    end

    def restitution_ids
      params[:restitution_ids].join('-')
    end

    def lien_pdf
      "/restitution_globale/show.pdf?restitution_ids=#{restitution_ids}"
    end
  end

  content do
    render partial: 'restitution_globale'
  end
end
