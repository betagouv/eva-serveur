# frozen_string_literal: true

class FooterComponent < ViewComponent::Base
  def initialize(avec_partenaires: true, partenaires: [], liens_navigation: nil, description: nil)
    @avec_partenaires = avec_partenaires
    @partenaires = partenaires
    @liens_navigation = liens_navigation || liens_navigation_par_defaut
    @description = description || description_par_defaut
  end

  attr_reader :avec_partenaires, :partenaires, :liens_navigation, :description

  def liens_gouvernementaux
    [
      { texte: "info.gouv.fr", url: "https://www.info.gouv.fr", externe: true },
      { texte: "service-public.fr", url: "https://www.service-public.fr", externe: true },
      { texte: "legifrance.gouv.fr", url: "https://www.legifrance.gouv.fr", externe: true },
      { texte: "data.gouv.fr", url: "https://www.data.gouv.fr", externe: true }
    ]
  end

  def liens_legaux
    [
      { texte: "Mentions légales", url: "#" },
      { texte: "Données personnelles", url: "#" },
      { texte: "Gestion des cookies", url: "#" },
      { texte: "Accessibilité", url: "#" }
    ]
  end

  private

  def liens_navigation_par_defaut
    [
      {
        titre: "Découvrir eva",
        liens: [
          { texte: "Qu'est-ce qu'eva ?", url: "#" },
          { texte: "Comment ça marche ?", url: "#" },
          { texte: "Qui peut utiliser eva ?", url: "#" }
        ]
      },
      {
        titre: "Cas d'usages",
        liens: [
          { texte: "Diagnostic", url: "#" },
          { texte: "Positionnement", url: "#" },
          { texte: "Suivi de progression", url: "#" }
        ]
      },
      {
        titre: "Ressources",
        liens: [
          { texte: "Documentation", url: "#" },
          { texte: "FAQ", url: "#" },
          { texte: "Support", url: "#" }
        ]
      },
      {
        titre: "En savoir plus",
        liens: [
          { texte: "À propos", url: "#" },
          { texte: "Contact", url: "#" },
          { texte: "Actualités", url: "#" }
        ]
      }
    ]
  end

  def description_par_defaut
    I18n.t("footer.description_par_defaut")
  end

  def partenaires_par_defaut
    [
      {
        logo: "logo_france_relance.svg",
        nom: I18n.t("footer.logo_france_relance"),
        url: "https://www.economie.gouv.fr/plan-national-relance-resilience-pnrr"
      },
      {
        logo: "logo_union_europeenne.png",
        nom: I18n.t("footer.logo_union_europeenne"),
        url: "https://next-generation-eu.europa.eu"
      }
    ]
  end
end
