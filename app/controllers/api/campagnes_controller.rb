# frozen_string_literal: true

module Api
  class CampagnesController < Api::BaseController
    before_action :trouve_campagne

    private

    def trouve_campagne
      questions_incluses = %i[questionnaires_questions questions]
      @campagne = Campagne.includes(
        situations_configurations: [
          { questionnaire: questions_incluses },
          { situation: [
            { questionnaire_entrainement: questions_incluses },
            { questionnaire: questions_incluses }
          ] }
        ]
      ).par_code(params[:code_campagne]).take!
    end
  end
end
