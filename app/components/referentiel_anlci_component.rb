# frozen_string_literal: true

class ReferentielAnlciComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(type)
    @type = type
    @badges_referentiel = badges_referentiel
  end

  def badges_referentiel
    commun = %w[profil1-blanc profil2-blanc profil3-blanc profil4-blanc]
    officiel = %w[profil_4h-blanc profil_4h_plus-blanc profil_4h_plus_plus-blanc]
    version_eva = %w[profil4_plus-blanc profil4_plus_plus-blanc]
    return (commun << officiel).flatten if @type == 'officiel'

    (commun << version_eva).flatten
  end
end
