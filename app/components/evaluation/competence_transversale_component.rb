# frozen_string_literal: true

class Evaluation
  class CompetenceTransversaleComponent < ViewComponent::Base
    include MarkdownHelper

    def initialize(competence:, interpretation:)
      @competence = competence
      @interpretation = interpretation
    end

    def url_competence
      "#{URL_COMPETENCES_SITE_VITRINE}#{@competence}/"
    end
  end
end
