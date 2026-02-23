# frozen_string_literal: true

class Pdf::HeaderEvaproComponent < ViewComponent::Base
  include StorageHelper
  renders_one :service_image

  def initialize(date:, beneficiaire:, structure:)
    @date = date
    @beneficiaire = beneficiaire
    @structure = structure
    @opco = structure&.opco
  end
end
