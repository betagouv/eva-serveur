# frozen_string_literal: true

class NomAnonymisableComponentStories < ViewComponent::Storybook::Stories
  class Ressource
    attr_reader :nom

    def initialize(nom, anonyme)
      @nom = nom
      @anonyme = anonyme
    end

    def anonyme?
      @anonyme
    end
  end
  story :nom_non_anonyme do
    constructor(Ressource.new('Jean Dupont', false))
  end
  story :nom_anonyme do
    constructor(Ressource.new('Jean Dupont', true))
  end
end
