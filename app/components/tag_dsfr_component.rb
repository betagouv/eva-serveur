class TagDsfrComponent < ViewComponent::Base
  TAILLES = { sm: "fr-tag--sm" }.freeze

  def initialize(libelle:, cliquable: false, taille: nil, icone: nil, **html_options)
    @libelle = libelle
    @cliquable = cliquable
    @taille = taille
    @icone = icone
    @html_options = html_options
  end

  def call
    if @cliquable
      content_tag(:button, @libelle, type: "button", **attributs)
    else
      content_tag(:p, @libelle, **attributs)
    end
  end

  private

  def attributs
    @html_options.merge(class: css_classes)
  end

  def css_classes
    classes = [ "fr-tag", TAILLES[@taille] ]
    classes += [ @icone, "fr-tag--icon-left" ] if @icone.present?
    classes << @html_options[:class]
    classes.compact.join(" ")
  end
end
