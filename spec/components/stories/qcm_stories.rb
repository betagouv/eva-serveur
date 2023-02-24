# frozen_string_literal: true

class QcmStories < ViewComponent::Storybook::Stories
  class Ressource
    attr_reader :id, :nom

    def initialize(id, nom)
      @id = id
      @nom = nom
    end
  end

  class Questionnaire
    attr_reader :nom, :question, :reponses

    def initialize(nom, question, reponses)
      @nom = nom
      @question = question
      @reponses = reponses
    end
  end

  story :default do
    ressource = Ressource.new('100', 'Didier')
    questionnaire = Questionnaire.new(:remediation, 'Question ?',
                                      { first: 'Réponse 1', two: 'Réponse 2' })

    constructor(ressource, questionnaire)
  end
end
