# frozen_string_literal: true

module Api
  class EvenementsController < ActionController::API
    def create
      evenement_data = params['evenement']
      @evenement = Evenement.create!(date: evenement_data['date'],
                                     type_evenement: evenement_data['type_evenement'],
                                     description: evenement_data['description'])
      render json: @evenement, status: :created
    end

    private

    def evenement_params
      params.permit(:date, :type_evenement, :description, :evenement)
    end
  end
end
