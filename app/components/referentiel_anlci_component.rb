class ReferentielAnlciComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize
    @badges_referentiel = badges_referentiel
  end

  def badges_referentiel
    %w[profil1 profil2 profil3 profil4 profil4_plus profil4_plus_plus]
  end
end
