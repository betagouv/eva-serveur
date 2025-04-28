# frozen_string_literal: true

class Evaluation
  class AnnexePositionnementComponent < ViewComponent::Base
    def initialize(restitution_globale:)
      @restitution_globale = restitution_globale
      @badges = %i[profil1 profil2 profil3 profil4 profil4_plus]
      @scope_badge = "admin.restitutions.references"
    end
  end
end
