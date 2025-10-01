class Pdf::EntetePageComponent < ViewComponent::Base
  def initialize(nom_beneficiaire:, code_beneficiaire:, date: nil, structure: nil)
    @nom_beneficiaire = nom_beneficiaire
    @code_beneficiaire = code_beneficiaire
    @date = date
    @structure = structure
  end
end
