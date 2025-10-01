class RejoindreStructureComponent < ViewComponent::Base
  def initialize(structure, current_compte)
    @structure = structure
    @current_compte = current_compte
  end
end
