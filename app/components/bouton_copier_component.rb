class BoutonCopierComponent < ViewComponent::Base
  def initialize(libelle:, texte:, classes: "", **options)
    @libelle = libelle
    @texte = texte
    @classes = classes
    @id_infobulle = "infobulle-copier-#{SecureRandom.uuid}"
    @options = options
    @aria = (options.delete(:aria) || {}).dup
    @aria[:describedby] = [ @aria[:describedby], @id_infobulle ].compact.join(" ")
  end
end
