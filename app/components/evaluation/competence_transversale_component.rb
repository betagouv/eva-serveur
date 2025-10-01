class Evaluation
  class CompetenceTransversaleComponent < ViewComponent::Base
    include MarkdownHelper

    def initialize(competence:, interpretation:)
      @competence = competence
      @interpretation = interpretation
    end

    def url_competence
      "#{ENV['URL_COMPETENCES']}/#{@competence}/"
    end
  end
end
