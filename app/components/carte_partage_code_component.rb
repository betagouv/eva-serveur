# frozen_string_literal: true

class CartePartageCodeComponent < ViewComponent::Base
  renders_one :footer

  def initialize(libelle_code: nil, code:, url: nil, description:)
    @libelle_code = libelle_code
    @code = code
    @url = url
    @description = description
  end
end
