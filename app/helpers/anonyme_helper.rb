# frozen_string_literal: true

module AnonymeHelper
  def nom_pour_evaluation(evaluation)
    prefixe_anonyme = evaluation.anonyme? ? inline_svg_tag('anonyme.svg') : ''
    prefixe_anonyme + evaluation.nom
  end
end
