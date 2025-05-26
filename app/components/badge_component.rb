# frozen_string_literal: true

class BadgeComponent < ViewComponent::Base
  def initialize(contenu:, html_class:, display_icon: false)
    @contenu = contenu
    @html_class = html_class
    @display_icon = display_icon
  end

  def display_icon_class
    @display_icon ? "" : "fr-badge--no-icon"
  end
end
