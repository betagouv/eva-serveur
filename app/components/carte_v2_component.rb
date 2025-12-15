# frozen_string_literal: true

class CarteV2Component < ViewComponent::Base
  def initialize(titre: nil)
    @titre = titre
  end
end
