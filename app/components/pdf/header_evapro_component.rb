class Pdf::HeaderEvaproComponent < ViewComponent::Base
  include StorageHelper
  renders_one :service_image

  def initialize(date:, beneficiaire:, structure:, avec_details: true)
    @date = date
    @beneficiaire = beneficiaire
    @structure = structure
    @avec_details = avec_details
    @opco = structure&.opco
  end
end
