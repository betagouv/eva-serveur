# frozen_string_literal: true

module Api
  class CampagnesController < ActionController::API
    before_action :trouve_campagne

    rescue_from ActiveRecord::RecordNotFound do
      head :not_found
    end

    def show
      @questions = @campagne.questionnaire&.questions || []
    end

    private

    def trouve_campagne
      @campagne = Campagne.find_by!(code: params[:code_campagne])
    end
  end
end
