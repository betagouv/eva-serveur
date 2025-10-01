class Evaluation
  class BienvenueComponent < ViewComponent::Base
    def initialize(restitution_globale:, bienvenue:)
      @restitution_globale = restitution_globale
      @bienvenue = bienvenue
    end
  end
end
