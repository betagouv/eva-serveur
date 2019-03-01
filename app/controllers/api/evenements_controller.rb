# frozen_string_literal: true

module Api
  class EvenementsController < ActionController::API
    def create
      return '' if params['evenement'].blank?

      evenement_data = params['evenement']
      @evenement = Evenement.create(date: evenement_data['date'],
                                    type_evenement: evenement_data['type_evenement'],
                                    description: evenement_data['description'])

      if @evenement.save
        render json: @evenement, status: :created
      else
        render json: @evenement.errors.full_messages, status: 422
      end
    end

    private

    def evenement_params
      params.permit(:date, :type_evenement, :description, :evenement)
    end
  end
end
