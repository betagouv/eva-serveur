class MiseEnAction
  class Questionnaire
    attr_reader :nom, :question, :reponses

    def initialize(nom)
      @nom = nom
      recupere_question_reponses
    end

    def recupere_question_reponses
      case @nom
      when :remediation
        @question = I18n.t("question.remediation")
        @reponses = MiseEnAction.remediations.excluding("indetermine")
      when :difficulte
        @question = I18n.t("question.difficulte")
        @reponses = MiseEnAction.difficultes.excluding("indetermine")
      end
    end
  end
end
