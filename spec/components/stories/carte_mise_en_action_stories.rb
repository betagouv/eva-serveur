# frozen_string_literal: true

class CarteMiseEnActionStories < ViewComponent::Storybook::Stories
  class Ressource
    attr_reader :id, :nom

    def initialize(id, nom)
      @id = id
      @nom = nom
    end

    def a_mise_en_action?
      false
    end
  end

  story :default do
    ressource = Ressource.new('100', "nom de l'évaluation")

    constructor(ressource)
  end
end
