# frozen_string_literal: true

module Api
  class EvenementsController < ActionController::API
    def create
      @evenement = Evenement.create(evenement_params)

      if @evenement.save
        render json: @evenement, status: :created
      else
        render json: @evenement.errors.full_messages, status: 422
      end
    end

    private

    def evenement_params
      parametres = params.require(:evenement).permit(:date, :type_evenement, :description)
      formate_date!(parametres)
    end

    def formate_date!(params)
      date = params['date']
      return params if date.blank?

      time_formate = Time.at(date.to_i / 1000.0)
      params['date'] = DateTime.parse(time_formate.to_s)
      params
    end
  end
end
