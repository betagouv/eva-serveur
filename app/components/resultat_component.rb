class ResultatComponent < ViewComponent::Base
  DOMAINES_PROFIL = %i[litteratie numeratie].freeze
  PROFILS_NON_CALCULES = %w[profil_aberrant indetermine].freeze
  REFERENTIELS_NIVEAU = { francais: :niveau_cefr, mathematiques: :niveau_cnef }.freeze
  COULEURS_BADGES_NIVEAU = {
    pre_A1: "fr-badge--orange-terre-battue",
    pre_X1: "fr-badge--orange-terre-battue",
    A1: "fr-badge--blue-cumulus",
    A2: "fr-badge--blue-cumulus",
    X1: "fr-badge--blue-cumulus",
    X2: "fr-badge--blue-cumulus",
    B1: "fr-badge--green-emeraude",
    Y1: "fr-badge--green-emeraude"
  }.freeze

  def initialize(domaine:, niveau:, avec_titre: true)
    @domaine = domaine
    @niveau = niveau
    @avec_titre = avec_titre
  end

  def badge
    return Badge::ProfilComponent.new(profil, @domaine) if DOMAINES_PROFIL.include?(@domaine)

    BadgeComponent.new(contenu: libelle_niveau,
                       class_couleur: COULEURS_BADGES_NIVEAU.fetch(@niveau&.to_sym,
                                                                   "fr-badge--grey-950"),
                       taille: "sm")
  end

  def domaine
    t("resultat.domaines.#{@domaine}")
  end

  def titre
    return t("resultat.titres.non_calcule") if @niveau.blank?

    t("resultat.titres.#{@niveau}", default: t("resultat.titres.non_calcule"))
  end

  private

  # Un profil aberrant ou indéterminé s'affiche comme non testé
  def profil
    PROFILS_NON_CALCULES.include?(@niveau) ? nil : @niveau
  end

  def libelle_niveau
    return t("resultat.badges.non_calcule") unless COULEURS_BADGES_NIVEAU.key?(@niveau&.to_sym)

    t("activerecord.attributes.evaluation_eva.interpretations." \
      "#{REFERENTIELS_NIVEAU[@domaine]}.#{@niveau}")
  end
end
