# frozen_string_literal: true

class HeaderComponent < ViewComponent::Base
  def initialize(logo:, logo_alt:, titre: nil)
    @logo = logo
    @logo_alt = logo_alt
    @titre = titre
  end
end
