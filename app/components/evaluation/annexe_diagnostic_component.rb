# frozen_string_literal: true

class Evaluation
  class AnnexeDiagnosticComponent < ViewComponent::Base
    def initialize(restitution_globale:)
      @restitution_globale = restitution_globale
      @badges_francais = %i[pre_A1 A1 A2 B1]
      @badges_maths = %i[pre_X1 X1 X2 Y1]
      @badges_francais_et_maths = %i[profil1 profil2 profil3 profil4 profil4_plus profil4_plus_plus]
      @scope_badge = "admin.restitutions.references"
    end
  end
end
