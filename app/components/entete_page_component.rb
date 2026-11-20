class EntetePageComponent < ViewComponent::Base
  renders_one :actions
  renders_one :barre

  def initialize(titre:, fil_ariane: [])
    @titre = titre
    @fil_ariane = fil_ariane
  end
end
