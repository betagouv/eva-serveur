# frozen_string_literal: true

class FooterComponent < ViewComponent::Base
  def initialize(avec_partenaires: true, partenaires: [], liens_navigation: nil, description: nil)
    @avec_partenaires = avec_partenaires
    @partenaires = partenaires
    @liens_navigation = liens_navigation || liens_navigation_par_defaut
    @description = description || description_par_defaut
  end

  attr_reader :avec_partenaires, :partenaires, :liens_navigation, :description

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
        logo: "logo/france_relance.svg",
        nom: I18n.t("footer.logo_france_relance"),
        url: "https://www.economie.gouv.fr/plan-national-relance-resilience-pnrr"
      },
      {
        logo: "logo/union_europeenne.png",
        nom: I18n.t("footer.logo_union_europeenne"),
        url: "https://next-generation-eu.europa.eu"
      }
    ]
  end
end
