# frozen_string_literal: true

class HeaderComponent < ViewComponent::Base
  def initialize(logo:, logo_alt:, titre: nil, tagline: nil, logo_url: nil)
    @logo = logo
    @logo_alt = logo_alt
    @logo_url = logo_url
    @titre = titre
    @tagline = tagline
  end
end
