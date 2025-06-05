# frozen_string_literal: true

class CartePartageCodeComponent < ViewComponent::Base
  renders_one :footer

  def initialize(code:, url: nil, description:)
    @code = code
    @url = url
    @description = description
  end
end
