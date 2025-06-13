# frozen_string_literal: true

class Evaluation
  class AlertInterpreterResultatsComponent < ViewComponent::Base
    def initialize
      @badges = %i[profil1 profil2 profil3 profil4 profil4_plus]
      @scope = "admin.restitutions.numeratie"
      @scope_badge = "admin.restitutions.references"
      @lien = "https://eva.anlci.gouv.fr/les-referentiels-devaluation/"
    end
  end
end
