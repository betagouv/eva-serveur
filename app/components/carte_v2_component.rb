# frozen_string_literal: true

class CarteV2Component < ViewComponent::Base
  def initialize(titre: nil, image: nil, classes: "")
    @titre = titre
    @image = image
    @classes = classes
  end
end
