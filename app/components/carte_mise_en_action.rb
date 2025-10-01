class CarteMiseEnAction < ViewComponent::Base
  include EvaluationHelper

  def initialize(ressource, carte_deroulee: false)
    @ressource = ressource
    @carte_deroulee = carte_deroulee
  end
end
