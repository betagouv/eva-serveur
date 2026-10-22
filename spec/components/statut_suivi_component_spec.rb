require "rails_helper"

describe StatutSuiviComponent, type: :component do
  {
    "suite_engagee" => [ "Suite engagée", "fr-badge--success" ],
    "reporte" => [ "Reporté", "fr-badge--yellow-tournesol" ],
    "pas_de_suite" => [ "Pas de suite", "fr-badge--info" ],
    "a_renseigner" => [ "À renseigner", "fr-badge--beige-gris-galet" ]
  }.each do |statut, (libelle, class_couleur)|
    it "affiche le badge « #{libelle} » pour le statut #{statut}" do
      render_inline(described_class.new(statut: statut))

      expect(page).to have_css(".fr-badge.fr-badge--sm.fr-badge--no-icon.#{class_couleur}",
                               text: libelle)
    end
  end

  context "quand l'évaluation n'est pas concernée" do
    before { render_inline(described_class.new(statut: "non_concerne")) }

    it "affiche un tiret sans badge" do
      expect(page).to have_css("span[aria-hidden='true']", text: "-")
      expect(page).not_to have_css(".fr-badge")
    end

    it "donne le texte alternatif aux lecteurs d'écran" do
      expect(page).to have_css(".fr-sr-only", text: "Pas de suivi")
    end

    it "explique le tiret dans une info-bulle" do
      expect(page).to have_css(".fr-tooltip",
                               text: "Pas de suivi : pas d'illettrisme potentiel",
                               visible: :all)
    end
  end
end
