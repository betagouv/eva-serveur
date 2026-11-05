class TagComponent < ViewComponent::Base
  def initialize(libelle:, cliquable: false, supprimable: false, url: nil, taille: nil,
                 icone: nil, **html_options)
    @libelle = libelle
    @cliquable = cliquable
    @supprimable = supprimable
    @url = url
    @taille = taille
    @icone = icone
    @html_options = html_options
  end

  private

  def attributs
    @html_options.merge(class: css_classes)
  end

  def css_classes
    classes = [ "fr-tag" ]
    classes << "fr-tag--#{@taille}" if @taille.present?
    classes << "fr-tag--dismiss" if @supprimable
    classes += [ @icone, "fr-tag--icon-left" ] if @icone.present?
    classes << @html_options[:class]
    classes.compact.join(" ")
  end
end
