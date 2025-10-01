class Evaluation
  class CompetencesTransversalesComponent < ViewComponent::Base
    include MarkdownHelper

    def initialize(restitution_globale:, completude_competences_transversales:)
      @restitution_globale = restitution_globale
      @interpretations = @restitution_globale.interpretations_competences_transversales
      @completude_competences_transversales = completude_competences_transversales
    end
  end
end
