# frozen_string_literal: true

class BadgeComponent < ViewComponent::Base
  def initialize(contenu:, class_couleur:, display_icon: false, taille: nil)
    @contenu = contenu
    @class_couleur = class_couleur
    @display_icon = display_icon
    @taille = taille
  end

  def css_classes
    classes = [ "fr-badge", @class_couleur, display_icon_class ]
    classes << "fr-badge--#{@taille}" if @taille.present?
    classes.compact.join(" ")
  end

  def display_icon_class
    @display_icon ? nil : "fr-badge--no-icon"
  end
end
