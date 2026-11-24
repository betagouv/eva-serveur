require "rails_helper"

describe DetailsEvaluationComponent, type: :component do
  let(:evaluation) do
    create(:evaluation, :eva, completude: completude,
                              debutee_le: Time.zone.local(2023, 5, 6, 18, 4))
  end
  let(:completude) { "complete" }
  let(:scope) { [ :admin, :evaluations_eva, :details_evaluation ] }

  before { render_inline(described_class.new(evaluation: evaluation)) }

  it "titre le bloc au nom du bénéficiaire" do
    expect(page).to have_css("h1", text: evaluation.beneficiaire.nom)
  end

  it "intitule la carte « Détails de l’évaluation »" do
    expect(page).to have_css("h2.fr-h4", text: I18n.t(:titre, scope: scope))
  end

  it "mène du code bénéficiaire à la fiche bénéficiaire" do
    expect(page).to have_link(evaluation.beneficiaire.code_beneficiaire,
                              href: "/admin/beneficiaires/#{evaluation.beneficiaire.id}",
                              class: %w[fr-link fr-link--sm])
  end

  it "mène de la campagne à sa page" do
    expect(page).to have_link(evaluation.campagne.libelle,
                              href: "/admin/campagnes/#{evaluation.campagne.id}",
                              class: %w[fr-link fr-link--sm])
  end

  it "affiche la date de début avec l'heure" do
    expect(page).to have_css(".details-evaluation__valeur",
                             text: I18n.l(evaluation.debutee_le, format: :avec_heure))
  end

  context "quand l'évaluation est complète" do
    it "n'affiche aucune alerte" do
      expect(page).to have_no_css(".fr-alert")
    end
  end

  context "quand l'évaluation est incomplète" do
    let(:completude) { "incomplete" }

    it "avertit dans la carte, sans bouton de fermeture" do
      expect(page).to have_css(".details-evaluation__carte .fr-alert.fr-alert--warning")
      expect(page).to have_no_css(".fr-alert--sm")
      expect(page).to have_no_css(".fr-alert .fr-btn--close")
    end

    it "décrit l'incomplétude dans un seul paragraphe, celui que pose dsfr_alert" do
      expect(page).to have_css(".fr-alert > p", count: 1)
      expect(page).to have_css(".fr-alert > p strong")
    end

    it "affiche le texte générique" do
      expect(page).to have_css(".fr-alert__title",
                               text: I18n.t(:titre, scope: scope + %i[incompletude incomplete]))
    end
  end

  context "quand seules les compétences de base sont incomplètes" do
    let(:completude) { "competences_de_base_incompletes" }

    it "affiche le texte des compétences de base" do
      expect(page).to have_css(".fr-alert__title",
                               text: I18n.t(:titre, scope: scope +
                                 %i[incompletude competences_de_base_incompletes]))
    end
  end

  context "quand seules les compétences transversales sont incomplètes" do
    let(:completude) { "competences_transversales_incompletes" }

    it "affiche le texte des compétences transversales" do
      expect(page).to have_css(".fr-alert__title",
                               text: I18n.t(:titre, scope: scope +
                                 %i[incompletude competences_transversales_incompletes]))
    end
  end
end
