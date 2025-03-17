# frozen_string_literal: true

class Evaluation
  class CompetencesTransversalesComponent < ViewComponent::Base
    include MarkdownHelper

    def initialize(restitution_globale:)
      @restitution_globale = restitution_globale
      @interpretations = @restitution_globale.interpretations_competences_transversales
    end
  end
end
