# frozen_string_literal: true

module Api
  class CampagnesController < Api::BaseController
    before_action :trouve_campagne

    def show
      @questions = @campagne.questionnaire&.questions || []
    end

    private

    def trouve_campagne
      @campagne = Campagne.find_by!(code: params[:code_campagne])
    end
  end
end
