# frozen_string_literal: true

class Badge::ProfilComponent < ViewComponent::Base
  COULEURS_BADGES_POSITIONNEMENT = {
    profil1: "fr-badge--orange-terre-battue",
    profil2: "fr-badge--orange-terre-battue",
    profil3: "fr-badge--blue-cumulus",
    profil4: "fr-badge--green-emeraude",
    profil4_plus: "fr-badge--green-emeraude",
    profil_4h: "fr-badge--green-emeraude",
    profil_4h_plus: "fr-badge--green-emeraude",
    profil_4h_plus_plus: "fr-badge--green-emeraude",
    profil_aberrant: "fr-badge--green-emeraude"
  }.freeze

  ##
  # @param [String] niveau :profil1, :profil2, :profil3, :profil4, :profil4_plus, :profil_
  # 4h, :profil_4h_plus, :profil_4h_plus_plus, :profil_aberrant
  # @param [String] competence :litteratie ou :numeratie
  def initialize(niveau, competence)
    @niveau = niveau
    @competence = competence
  end

  def call
    render BadgeComponent.new(
      contenu: traduit_niveau,
      class_couleur: couleur_badges_positionnement(@niveau),
      display_icon: false,
      taille: "sm"
    )
  end

  private

  def couleur_badges_positionnement(valeur)
    COULEURS_BADGES_POSITIONNEMENT[valeur&.to_sym] || "fr-badge--grey-950"
  end

  def traduit_niveau
    scope = "activerecord.attributes.evaluation.interpretations"
    return t(".non_teste", scope: scope) if @niveau.blank?

    interpretation = "positionnement_niveau_#{@competence}".to_sym

    return t("#{interpretation}.indetermine", scope: scope) if @niveau.blank?

    t("#{interpretation}.#{@niveau}", scope: scope)
  end
end
