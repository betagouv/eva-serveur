# frozen_string_literal: true

ActiveAdmin.register_page 'Evaluation Globale' do
  menu false

  controller do
    helper_method :evaluation_globale
    
    def instancie_evaluation(situation, evenements)
      classe_evaluation = {
        'inventaire' => Evaluation::Inventaire,
        'controle' => Evaluation::Controle
      }

      classe_evaluation[situation].new(evenements)
    end

    def evaluation_depuis_id(id)
      evenement = Evenement.find id
      evenements = Evenement.where(session_id: evenement.session_id).order(:date)
      instancie_evaluation evenement.situation, evenements
    end

    def evaluation_globale
      evaluations = params[:evaluation_ids].map do |id|
        evaluation_depuis_id id
      end
      Evaluation::Globale.new evaluations: evaluations
    end
  end

  content do
    render partial: 'evaluation_globale'
  end
end
