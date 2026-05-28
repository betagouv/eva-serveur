class Evaluation
  class CompetenceTransversaleComponent < ViewComponent::Base
    include MarkdownHelper

    def initialize(competence:, interpretation:)
      @competence = competence
      @interpretation = interpretation
    end

    def url_competence
      "#{ENV['URL_SITE_VITRINE']}/#{::Competence::COMPETENCES_TRANSVERSALES[@competence]}/"
    end
  end
end
