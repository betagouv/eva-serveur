# frozen_string_literal: true

class CarteV2Component < ViewComponent::Base
  def initialize(titre: nil, image: nil)
    @titre = titre
    @image = image
  end
end
