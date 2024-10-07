# frozen_string_literal: true

class ReferentielAnlciComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(type)
    @type = type
    @badges_referentiel = badges_referentiel
  end

  def badges_referentiel
    commun = %w[profil1-referentiel profil2-referentiel profil3-referentiel profil4-referentiel]
    officiel = %w[profil_4h-referentiel profil_4h_plus-referentiel profil_4h_plus_plus-referentiel]
    version_eva = %w[profil4_plus-referentiel profil4_plus_plus-referentiel]
    return (commun << officiel).flatten if @type == 'officiel'

    (commun << version_eva).flatten
  end
end
