class Evaluation
  class AnnexePositionnementComponent < ViewComponent::Base
    def initialize(restitution_globale:)
      @restitution_globale = restitution_globale
      @badges_numeratie = %i[profil1 profil2 profil3 profil4 profil4_plus]
      @badges_litteratie = %i[profil1 profil2 profil3 profil4 profil4_plus profil4_plus_plus]
      @scope_badge = "admin.restitutions.references"
    end
  end
end
