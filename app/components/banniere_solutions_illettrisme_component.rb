# frozen_string_literal: true

class BanniereSolutionsIllettrismeComponent < ViewComponent::Base
  def initialize(current_compte: nil, evaluation: nil, asterisque: false)
    @current_compte = current_compte
    @evaluation = evaluation
    @asterisque = asterisque
  end

  def code_commune
    return campagne_structure&.code_commune if @evaluation.present?

    @current_compte&.structure&.code_commune
  end

  def lien
    if code_commune.present?
      t("banniere_solutions_illettrisme.lien_commune", code_commune: code_commune)
    else
      t("banniere_solutions_illettrisme.lien")
    end
  end

  private

  def campagne_structure
    @evaluation.campagne&.compte&.structure
  end
end
