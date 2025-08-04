# frozen_string_literal: true

module BeneficiaireHelper
  def url_beneficiaire(code)
    Addressable::URI.escape("#{URL_CLIENT}?code_beneficiaire=#{code}")
  end
end
