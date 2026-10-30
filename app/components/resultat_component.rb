class ResultatComponent < ViewComponent::Base
  COULEURS = {
    profil1: "alerte",
    profil2: "alerte",
    profil3: "intermediaire",
    profil4: "succes",
    profil_4h: "succes",
    profil_4h_plus: "succes",
    profil_4h_plus_plus: "succes",
    profil4_plus: "succes",
    profil4_plus_plus: "succes",
    pre_A1: "alerte",
    A1: "intermediaire",
    A2: "intermediaire",
    B1: "succes",
    pre_X1: "alerte",
    X1: "intermediaire",
    X2: "intermediaire",
    Y1: "succes"
  }.freeze
  DOMAINES_PROFIL = %i[litteratie numeratie].freeze

  def initialize(domaine:, niveau:)
    @domaine = domaine
    @niveau = COULEURS.key?(niveau&.to_sym) ? niveau.to_sym : :non_calcule
  end

  def classes_pastille
    classes = [ "resultat__pastille", "resultat__pastille--#{couleur}" ]
    classes << "resultat__pastille--ronde" if DOMAINES_PROFIL.include?(@domaine)
    classes.join(" ")
  end

  def couleur
    COULEURS.fetch(@niveau, "desactive")
  end

  def pastille
    t("resultat.pastilles.#{@niveau}")
  end

  def domaine
    t("resultat.domaines.#{@domaine}")
  end

  def titre
    t("resultat.titres.#{@niveau}")
  end
end
