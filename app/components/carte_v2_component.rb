# frozen_string_literal: true

class CarteV2Component < ViewComponent::Base
  def initialize(titre: nil, sous_titre: nil, image: nil, classes: "")
    @titre = titre
    @sous_titre = sous_titre
    @image = image
    @classes = classes
  end
end
