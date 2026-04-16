# frozen_string_literal: true

class Pdf::HeaderEvaComparaisonComponent < ViewComponent::Base
  def initialize(nom_beneficiaire:, code_beneficiaire:)
    @nom_beneficiaire = nom_beneficiaire
    @code_beneficiaire = code_beneficiaire
  end
end
