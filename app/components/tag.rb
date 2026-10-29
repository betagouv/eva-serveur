class Tag < ViewComponent::Base
  def initialize(contenu, supprimable: false, url: nil, taille: nil)
    @contenu = contenu
    @supprimable = supprimable
    @url = url
    @taille = taille
  end

  def css_classes
    classes = [ "fr-tag" ]
    classes << "fr-tag--dismiss" if @supprimable
    classes << "fr-tag--#{@taille}" if @taille.present?
    classes.join(" ")
  end
end
