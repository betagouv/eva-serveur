# frozen_string_literal: true

module Api
  class CampagnesController < Api::BaseController
    before_action :trouve_campagne

    def show
      @questions = @campagne.questionnaire&.questions || []
    end

    private

    def trouve_campagne
      @campagne = Campagne.par_code(params[:code_campagne]).take!
    end
  end
end
