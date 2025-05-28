# frozen_string_literal: true

module Api
  class CampagnesController < Api::BaseController
    before_action :trouve_et_verifie_campagne, :preload_questions

    def show; end

    private

    def trouve_et_verifie_campagne
      @campagne = Campagne.par_code(params[:code_campagne]).take!

      unless @campagne.active?
        render json: { error: I18n.t(".errors.campagne_inactive") }, status: :forbidden
        return
      end

      precharge_inclusions
    end

    def precharge_inclusions
      questions_incluses = %i[questionnaires_questions questions]
      @campagne = @campagne.class.includes(
        situations_configurations: [
          { questionnaire: questions_incluses },
          { situation: [
            { questionnaire_entrainement: questions_incluses },
            { questionnaire: questions_incluses }
          ] }
        ]
      ).find(@campagne.id)
    end

    def preload_questions
      recupere_questions.group_by(&:type).each do |type, questions|
        Question.preload_questions_pour_type(type, questions)
      end
    end

    def recupere_questions
      questions = []
      @campagne.situations_configurations.each do |situation_configuration|
        questionnaire = situation_configuration.questionnaire_utile
        questions << questionnaire&.questions

        questionnaire_entrainement = situation_configuration.situation.questionnaire_entrainement
        questions << questionnaire_entrainement&.questions
      end
      questions.flatten!
      questions.compact!
      questions
    end
  end
end
