# frozen_string_literal: true

class CarteAvecMenuDeroulantStories < ViewComponent::Storybook::Stories
  class Ressource
    attr_reader :id, :nom

    def initialize(id, nom)
      @id = id
      @nom = nom
    end
  end

  story :default do
    ressource = Ressource.new('100', 'Didier')
    question = 'Question'
    reponses = { one: 'reponse 1', two: 'reponse 2', three: 'reponse 3' }

    constructor(ressource, question, reponses) do
      'Ceci est une carte.'
    end
  end
end
