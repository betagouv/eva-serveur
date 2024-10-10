# frozen_string_literal: true

class ReferentielAnlciComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize
    @badges_referentiel = badges_referentiel
  end

  def badges_referentiel
    %w[profil1-referentiel profil2-referentiel profil3-referentiel profil4-referentiel
       profil4_plus-referentiel profil4_plus_plus-referentiel]
  end
end
