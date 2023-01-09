# frozen_string_literal: true

class CarteComponent < ViewComponent::Base
  def initialize(nom, url)
    @nom = nom
    @url = url
  end
end
