# frozen_string_literal: true

class BadgeComponent < ViewComponent::Base
  def initialize(contenu:, html_class:, display_icon: false, taille: nil)
    @contenu = contenu
    @html_class = html_class
    @display_icon = display_icon
    @taille = taille
  end

  def css_classes
    classes = [ "fr-badge", @html_class, display_icon_class ]
    classes << "fr-badge--#{@taille}" if @taille.present?
    classes.compact.join(" ")
  end

  def display_icon_class
    @display_icon ? "" : "fr-badge--no-icon"
  end
end
