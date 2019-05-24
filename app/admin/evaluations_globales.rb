# frozen_string_literal: true

ActiveAdmin.register_page 'Evaluation Globale' do
  menu false

  controller do
    helper_method :evaluation_globale

    def evaluation_globale
      evaluations = params[:evaluation_ids].map do |id|
        FabriqueEvaluation.depuis_evenement_id id
      end
      Evaluation::Globale.new evaluations: evaluations
    end
  end

  content do
    render partial: 'evaluation_globale'
  end
end
