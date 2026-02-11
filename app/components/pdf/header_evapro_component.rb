# frozen_string_literal: true

class Pdf::HeaderEvaproComponent < ViewComponent::Base
  def initialize(date:, beneficiaire:)
    @date = date
    @beneficiaire = beneficiaire
  end
end
