require 'rails_helper'

describe 'Admin - Comparaison', type: :feature do
  let(:compte) { create :compte }
  let(:beneficiaire) { create :beneficiaire }
  let(:evaluations) do
    [
      create(:evaluation, beneficiaire: beneficiaire),
      create(:evaluation, beneficiaire: beneficiaire)
    ]
  end

  before { connecte(compte) }

  describe 'index' do
    before do
      visit(admin_comparaison_path(
        beneficiaire_id: beneficiaire.id, evaluation_ids: evaluations.map(&:id)
      ))
    end

    it do
      expect(page).to have_http_status(200)
      expect(page).to have_content 'Comparer les évaluations'
    end
  end

  describe "affichage des explications littératie" do
    let(:campagne) { create(:campagne) }

    let(:evaluation_1) do
      create(
        :evaluation, beneficiaire: beneficiaire,
        campagne: campagne,
        debutee_le: Date.new(2026, 1, 10),
        terminee_le: Date.new(2026, 1, 15)
      )
    end
    let(:evaluation_2) do
      create(
        :evaluation, beneficiaire: beneficiaire,
        campagne: campagne,
        debutee_le: Date.new(2026, 2, 10),
        terminee_le: Date.new(2026, 2, 15)
      )
    end

    before do
      comparaison_evaluations = instance_double(ComparaisonEvaluations)

      allow(ComparaisonEvaluations).to receive(:new).and_return(comparaison_evaluations)
      allow(comparaison_evaluations).to receive(:valid?).and_return(true)
      allow(comparaison_evaluations).to receive(:tableau_comparaison)
        .with(:litteratie)
        .and_return(tableau_litteratie)
      allow(comparaison_evaluations).to receive(:tableau_comparaison)
        .with(:numeratie)
        .and_return([])
    end

    context "avec une seule passation" do
      let(:tableau_litteratie) do
        [
          { evaluation: evaluation_1, profil: :profil2, restitution: nil, sous_competences: {} },
          { evaluation: nil }
        ]
      end

      it "affiche un seul paragraphe littératie" do
        visit(admin_comparaison_path(
          beneficiaire_id: beneficiaire.id, evaluation_ids: [ evaluation_1.id ]
        ))

        expect(page).to have_css(".page-comparaison__texte-profil", text: "la personne évaluée")
        expect(page).to have_content(I18n.t("admin.comparaison.litteratie.textes_profils.profil2"))
      end
    end

    context "avec deux passations et profils identiques" do
      let(:tableau_litteratie) do
        [
          { evaluation: evaluation_1, profil: :profil4, restitution: nil,
            sous_competences: {}
          },
          { evaluation: evaluation_2, profil: :profil4, restitution: nil,
            sous_competences: {}
          }
        ]
      end

      it "affiche la phrase de maintien sur le second paragraphe" do
        visit(admin_comparaison_path(
          beneficiaire_id: beneficiaire.id, evaluation_ids: [ evaluation_1.id, evaluation_2.id ]
        ))

        expect(page).to have_content("maintient un niveau général identique")
        expect(page).to have_content("Profil 4")
      end
    end
  end

  describe "affichage des explications numératie" do
    let(:campagne) { create(:campagne) }

    let(:evaluation_1) do
      create(
        :evaluation, beneficiaire: beneficiaire,
        campagne: campagne,
        debutee_le: Date.new(2026, 1, 10),
        terminee_le: Date.new(2026, 1, 15)
      )
    end
    let(:evaluation_2) do
      create(
        :evaluation, beneficiaire: beneficiaire,
        campagne: campagne,
        debutee_le: Date.new(2026, 2, 10),
        terminee_le: Date.new(2026, 2, 15)
      )
    end

    before do
      comparaison_evaluations = instance_double(ComparaisonEvaluations)

      allow(ComparaisonEvaluations).to receive(:new).and_return(comparaison_evaluations)
      allow(comparaison_evaluations).to receive(:valid?).and_return(true)
      allow(comparaison_evaluations).to receive(:tableau_comparaison)
        .with(:litteratie)
        .and_return([])
      allow(comparaison_evaluations).to receive(:tableau_comparaison)
        .with(:numeratie)
        .and_return(tableau_numeratie)
    end

    context "avec une seule passation" do
      let(:tableau_numeratie) do
        [
          { evaluation: evaluation_1, profil: :profil2, restitution: nil, sous_competences: {} },
          { evaluation: nil }
        ]
      end

      it "affiche un seul paragraphe numératie" do
        visit(admin_comparaison_path(
          beneficiaire_id: beneficiaire.id, evaluation_ids: [ evaluation_1.id ]
        ))

        expect(page).to have_css(".page-comparaison__texte-profil", text: "la personne évaluée")
        expect(page).to have_content(I18n.t("admin.comparaison.numeratie.textes_profils.profil2"))
      end
    end

    context "avec deux passations et profils identiques" do
      let(:tableau_numeratie) do
        [
          { evaluation: evaluation_1, profil: :profil4_plus, restitution: nil,
            sous_competences: {}
          },
          { evaluation: evaluation_2, profil: :profil4_plus, restitution: nil,
            sous_competences: {}
          }
        ]
      end

      it "affiche la phrase de maintien sur le second paragraphe" do
        visit(admin_comparaison_path(
          beneficiaire_id: beneficiaire.id, evaluation_ids: [ evaluation_1.id, evaluation_2.id ]
        ))

        expect(page).to have_content("maintient un niveau général identique")
        expect(page).to have_content("Profil 4+")
      end
    end
  end
end
