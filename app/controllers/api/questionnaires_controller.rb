# frozen_string_literal: true

module Api
  class QuestionnairesController < Api::BaseController
    def show
      render json: questions
    end

    private

    def questions
      questionnaire = Questionnaire.find(params[:id])
      questions_ordonnes = questionnaire.questions.select(:id, :type)
      questions_par_type = questions_par_type(questions_ordonnes)

      questions = []
      questions_ordonnes.each_with_index do |question, index|
        type = question.type
        id = question.id

        questions[index] = questions_par_type[type].find { |q| q.id == id }
      end
      questions
    end

    def questions_par_type(questions)
      questions_ids_groupes = questions.group_by(&:type)
      questions_par_type = {}

      # Charger les questions par type avec les associations spécifiques
      questions_ids_groupes.each do |type, question_objects|
        ids = question_objects.map(&:id) # Récupérer les ids des questions pour chaque type

        association_to_include = [:bonne_reponse] if type == QuestionSaisie.to_s
        association_to_include = [:choix]         if type == QuestionQcm.to_s

        questions_par_type[type] =
          Question.where(id: ids).includes(association_to_include)
      end

      questions_par_type
    end
  end
end
