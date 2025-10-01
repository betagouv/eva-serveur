class PastilleComponent < ViewComponent::Base
  def initialize(etiquette: nil, tooltip_content: nil, couleur: nil)
    @etiquette = etiquette
    @tooltip_content = tooltip_content
    @couleur = couleur
  end
end
