class Evaluation
  class AlertAnnexeComponent < ViewComponent::Base
    def initialize
      @lien_referentiel = "#{ENV['URL_SITE_VITRINE']}/referentiels/"
      @lien_positionnement = "#{ENV['URL_SITE_VITRINE']}/positionnement/"
    end
  end
end
