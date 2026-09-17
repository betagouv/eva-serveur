class BadgeComponent < ViewComponent::Base
  def initialize(contenu:, class_couleur:, display_icon: false, taille: nil, sans_marge_basse: true)
    @contenu = contenu
    @class_couleur = class_couleur
    @display_icon = display_icon
    @taille = taille
    @sans_marge_basse = sans_marge_basse
  end

  def css_classes
    classes = [ "fr-badge", @class_couleur, display_icon_class ]
    classes << "fr-badge--#{@taille}" if @taille.present?
    classes << "fr-mb-0" if @sans_marge_basse
    classes.compact.join(" ")
  end

  def display_icon_class
    @display_icon ? nil : "fr-badge--no-icon"
  end
end
