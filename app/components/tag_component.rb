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

  # Le JS du DSFR retire le tag du DOM au clic ; tag_supprimable.js envoie alors en
  # arrière-plan un PATCH vers url_suppression (s'il y en a une).
  def attributs_suppression
    data = (@html_options[:data] || {}).merge(url_suppression: @url)
    attributs.merge(data: data.compact)
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
