class CardComponent < ViewComponent::Base
  SIZE_CLASSES = {
    sm: "fr-card--sm",
    md: "",
    lg: "fr-card--lg"
  }.freeze

  def initialize(
    url: nil,
    titre: nil,
    description: nil,
    image_url: nil,
    image_alt: nil,
    bouton_label: nil,
    bouton_url: nil,
    bouton_attributes: {},
    size: :md,
    html_attributes: {},
    classes: []
  )
    @url = url
    @titre = titre
    @description = description
    @image_url = image_url
    @image_alt = image_alt || "[À MODIFIER - vide ou texte alternatif de l'image]"
    @bouton_label = bouton_label
    @bouton_url = bouton_url || url
    @bouton_attributes = bouton_attributes
    @size = size
    @html_attributes = html_attributes
    @classes = classes
  end

  def card_classes
    base_classes = [ "fr-card" ]
    base_classes << SIZE_CLASSES[@size] if SIZE_CLASSES[@size].present?
    base_classes << "fr-enlarge-link" if @url.present?
    base_classes.concat(@classes)
    base_classes.compact.join(" ")
  end

  def has_image?
    @image_url.present?
  end

  def has_bouton?
    @bouton_label.present? && @bouton_url.present?
  end

  def titre_avec_lien?
    @url.present? && !has_bouton?
  end
end
