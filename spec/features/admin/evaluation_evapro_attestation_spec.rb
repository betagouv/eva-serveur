require "rails_helper"

describe "Admin - Attestation de passation Evapro", type: :feature do
  before do
    Bullet.enable = false
    connecte(compte)
  end

  after { Bullet.enable = true }

  let(:structure_evapro) { create(:structure_locale, usage: AvecUsage::USAGE_EVAPRO) }
  let(:compte) { create :compte, role: "admin", structure: structure_evapro }
  let(:campagne) { create(:campagne, :avec_parcours_evapro, compte: compte) }
  let(:beneficiaire) { create(:beneficiaire, compte: compte) }
  let(:evaluation) do
    create(:evaluation, :evapro, campagne: campagne, beneficiaire: beneficiaire,
                                 completude: completude)
  end
  let(:libelle_bouton) do
    I18n.t("admin.evaluations_evapro.restitution_globale.bouton_attestation")
  end

  context "quand la fonctionnalité est active" do
    before { allow(AttestationPassation).to receive(:active?).and_return(true) }

    context "quand le questionnaire est complet" do
      let(:completude) { :complete }

      it "affiche le bouton de téléchargement de l'attestation" do
        visit admin_evaluation_evapro_path(evaluation)

        expect(page).to have_link(libelle_bouton)
      end
    end

    context "quand le questionnaire est incomplet" do
      let(:completude) { :incomplete }

      it "n'affiche pas le bouton" do
        visit admin_evaluation_evapro_path(evaluation)

        expect(page).to have_no_link(libelle_bouton)
      end
    end

    context "quand le compte a créé la campagne sans avoir passé le diagnostic" do
      let(:completude) { :complete }
      let(:personne_evaluee) do
        create :compte, role: "conseiller", structure: structure_evapro
      end
      let(:beneficiaire) { create(:beneficiaire, compte: personne_evaluee) }

      it "affiche le bouton, comme celui de l'export" do
        visit admin_evaluation_evapro_path(evaluation)

        expect(page).to have_link(libelle_bouton)
      end
    end
  end

  context "quand la fonctionnalité est inactive" do
    let(:completude) { :complete }

    before { allow(AttestationPassation).to receive(:active?).and_return(false) }

    it "n'affiche pas le bouton" do
      visit admin_evaluation_evapro_path(evaluation)

      expect(page).to have_no_link(libelle_bouton)
    end
  end

  describe "téléchargement" do
    let(:completude) { :complete }

    context "quand la fonctionnalité est active" do
      before { allow(AttestationPassation).to receive(:active?).and_return(true) }

      it "lance la génération du PDF depuis le bouton" do
        visit admin_evaluation_evapro_path(evaluation)

        expect do
          click_link libelle_bouton
        end.to have_enqueued_job(Pdf::GenerationJob).with { |_jeton, _html, nom|
          expect(nom).to eq("#{evaluation.debutee_le.strftime('%Y%m%d-%H%M')}-" \
                            "attestation-passation-#{beneficiaire.nom}.pdf")
        }
        expect(page).to have_current_path(%r{/admin/pdf_generations/})
      end

      it "atteste la passation sans aucun résultat" do
        expect do
          visit telecharger_attestation_admin_evaluation_evapro_path(evaluation)
        end.to have_enqueued_job(Pdf::GenerationJob).with { |_jeton, html, _nom|
          expect(html).to include(beneficiaire.nom)
          expect(html).to include(structure_evapro.nom)
          expect(html).to include(I18n.l(evaluation.debutee_le.to_date, format: :long))
          expect(html).to include(I18n.l(Date.current, format: :long))
          expect(html).not_to include(I18n.t("admin.evaluations_evapro.bilan_evapro.titre"))
        }
      end

      context "quand le compte ne peut pas lire la restitution" do
        let(:autre_structure) { create(:structure_locale, usage: AvecUsage::USAGE_EVAPRO) }
        let(:createur_campagne) { create :compte, role: "admin", structure: autre_structure }
        let(:campagne) do
          create(:campagne, :avec_parcours_evapro, compte: createur_campagne)
        end

        it "refuse la génération" do
          expect do
            visit telecharger_attestation_admin_evaluation_evapro_path(evaluation)
          end.not_to have_enqueued_job(Pdf::GenerationJob)
        end
      end
    end

    context "quand la fonctionnalité est inactive" do
      before { allow(AttestationPassation).to receive(:active?).and_return(false) }

      it "renvoie une 404" do
        expect do
          visit telecharger_attestation_admin_evaluation_evapro_path(evaluation)
        end.not_to have_enqueued_job(Pdf::GenerationJob)
        expect(page).to have_http_status(:not_found)
      end
    end
  end
end
