# frozen_string_literal: true

class Evaluation
  class AlertAnnexeComponent < ViewComponent::Base
    def initialize
      @lien_referentiel = "https://eva.anlci.gouv.fr/referentiels/"
      @lien_positionnement = "https://eva.anlci.gouv.fr/positionnement/"
    end
  end
end
