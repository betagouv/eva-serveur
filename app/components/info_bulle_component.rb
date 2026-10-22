class InfoBulleComponent < ViewComponent::Base
  def initialize(texte:)
    @texte = texte
    @id = "info-bulle-#{SecureRandom.uuid}"
  end
end
