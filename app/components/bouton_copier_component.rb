class BoutonCopierComponent < ViewComponent::Base
  def initialize(libelle:, texte:, classes: "", **options)
    @libelle = libelle
    @texte = texte
    @classes = classes
    @options = options
    @id_infobulle = "infobulle-copier-#{SecureRandom.uuid}"
  end
end
