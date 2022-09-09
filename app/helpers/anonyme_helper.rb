# frozen_string_literal: true

module AnonymeHelper
  def nom_pour_ressource(ressource)
    prefixe_anonyme = ressource.anonyme? ? inline_svg_tag('anonyme.svg') : ''
    prefixe_anonyme + ressource.nom
  end
end
