# frozen_string_literal: true

class CarteComponent < ViewComponent::Base
  def initialize(url, classes: nil)
    @url = url
    @classes = classes
  end
end
