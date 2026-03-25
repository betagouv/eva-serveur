class CarteMiseEnAction < ViewComponent::Base
  def initialize(ressource, carte_deroulee: false)
    @ressource = ressource
    @carte_deroulee = carte_deroulee
  end
end
