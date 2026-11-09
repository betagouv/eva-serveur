require "rails_helper"

describe "Admin - Mise en action", :js, type: :feature do
  let(:mon_compte) { create :compte, role: "admin" }
  let(:ma_campagne) { create :campagne, compte: mon_compte }
  let!(:evaluation) do
    create :evaluation, :eva, campagne: ma_campagne,
                              synthese_competences_de_base: :illettrisme_potentiel,
                              completude: "complete"
  end
  let(:mise_en_action) { MiseEnAction.find_by(evaluation_id: evaluation.id) }
  let(:precisez) { I18n.t("activerecord.attributes.mise_en_action.precision_autre") }
  let(:enregistrer) { I18n.t("qualification_mise_en_action.enregistrer") }

  before do
    Bullet.enable = false
    connecte(mon_compte)
    # En mode JS, la connexion n'est pas terminée au retour de connecte
    page.assert_current_path(admin_dashboard_path)
  end

  after { Bullet.enable = true }

  describe "sur le détail d'une évaluation" do
    let(:formation_metier) do
      I18n.t("activerecord.attributes.mise_en_action.remediation.formation_metier")
    end
    let(:accompagnement_necessaire) do
      I18n.t("activerecord.attributes.mise_en_action.difficulte.accompagnement_necessaire")
    end

    before { visit admin_evaluation_eva_path(evaluation) }

    it "remplace la question par le choix du type d'aide quand on répond Oui" do
      within(".card__banner--illettrisme") { click_button "Oui" }

      expect(page).to have_css(".questions-remediation", visible: :visible,
                               text: I18n.t("qualification_mise_en_action.titre_remediation"))
      expect(page).to have_css(".questions-difficulte", visible: :hidden)
      expect(page).to have_no_button("Oui")
      expect(mise_en_action.effectuee).to be(true)
    end

    it "remplace la question par le choix de la raison quand on répond Non" do
      within(".card__banner--illettrisme") { click_button "Non" }

      expect(page).to have_css(".questions-difficulte", visible: :visible,
                               text: I18n.t("qualification_mise_en_action.titre_difficulte"))
      expect(page).to have_css(".questions-remediation", visible: :hidden)
      expect(page).to have_no_button("Non")
      expect(mise_en_action.effectuee).to be(false)
    end

    it "enregistre le type d'aide dès qu'on le choisit" do
      within(".card__banner--illettrisme") do
        click_button "Oui"
        within(".questions-remediation") { click_button formation_metier }

        expect(page).to have_css(".questions-remediation", visible: :hidden)
        expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_true"))
        expect(page).to have_css("[data-reponse='true'] .tag", text: formation_metier)
        expect(page).to have_css(
          "[data-reponse='true'] .mise-en-action-repondue__date",
          text: I18n.t("reponse_mise_en_action.repondue_le",
                       date: I18n.l(Date.current, format: :short))
        )
      end
      expect(mise_en_action.reload.remediation).to eq("formation_metier")
    end

    it "enregistre la raison dès qu'on la choisit" do
      within(".card__banner--illettrisme") do
        click_button "Non"
        within(".questions-difficulte") { click_button accompagnement_necessaire }

        expect(page).to have_css(".questions-difficulte", visible: :hidden)
        expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_false"))
        expect(page).to have_css("[data-reponse='false'] .tag", text: accompagnement_necessaire)
      end
      expect(mise_en_action.reload.difficulte).to eq("accompagnement_necessaire")
    end

    it "repose la question quand on change de réponse avant de choisir" do
      within(".card__banner--illettrisme") do
        click_button "Oui"
        within(".questions-remediation") do
          click_link I18n.t("qualification_mise_en_action.modifier")
        end

        expect(page).to have_button("Oui")
        expect(page).to have_button("Non")
        expect(page).to have_css(".questions-remediation", visible: :hidden)
      end
    end
  end

  describe "sur le détail d'une évaluation, réponse « Autre »" do
    let(:autre) { I18n.t("activerecord.attributes.mise_en_action.remediation.autre") }
    let(:formation_metier) do
      I18n.t("activerecord.attributes.mise_en_action.remediation.formation_metier")
    end

    before do
      visit admin_evaluation_eva_path(evaluation)
      within(".card__banner--illettrisme") { click_button "Oui" }
    end

    it "ouvre « Précisez » sans rien enregistrer" do
      within(".questions-remediation") do
        click_button autre

        expect(page).to have_css("button[aria-pressed='true']", text: autre)
        expect(page).to have_field(precisez)
        expect(page).to have_button(enregistrer)
        expect(page).to have_field(precisez, focused: true)
      end
      expect(mise_en_action.reload.remediation).to be_nil
    end

    it "refuse d'enregistrer une précision vide ou faite d'espaces" do
      message = I18n.t("activerecord.errors.models.mise_en_action.attributes" \
                       ".precision_autre.blank_remediation")
      within(".questions-remediation") do
        click_button autre
        click_button enregistrer

        expect(page).to have_css(".fr-message--error", text: message)

        fill_in precisez, with: "   "
        click_button enregistrer

        expect(page).to have_css(".fr-message--error", text: message)
        expect(page).to have_field(precisez, focused: true)
      end
      expect(mise_en_action.reload.remediation).to be_nil
    end

    it "n'affiche plus l'erreur une fois la précision enregistrée" do
      within(".card__banner--illettrisme") do
        within(".questions-remediation") do
          click_button autre
          click_button enregistrer
          fill_in precisez, with: "atelier numérique"
          click_button enregistrer
        end
        expect(page).to have_css("div[data-reponse='true']",
                                 text: I18n.t("reponse_mise_en_action.autre",
                                              precision: "atelier numérique"))
        click_link I18n.t("reponse_mise_en_action.modifier")
        click_button "Oui"

        within(".questions-remediation") do
          expect(page).to have_field(precisez, with: "atelier numérique")
          expect(page).to have_no_css(".fr-message--error")
        end
      end
    end

    it "enregistre « Autre » avec sa précision et l'affiche" do
      within(".card__banner--illettrisme") do
        within(".questions-remediation") do
          click_button autre
          fill_in precisez, with: "atelier numérique"
          click_button enregistrer
        end

        expect(page).to have_css(".questions-remediation", visible: :hidden)
        expect(page).to have_css("[data-reponse='true']",
                                 text: I18n.t("reponse_mise_en_action.autre",
                                              precision: "atelier numérique"))
        expect(page).to have_css(
          "[data-reponse='true'] .mise-en-action-repondue__date",
          text: I18n.t("reponse_mise_en_action.repondue_le",
                       date: I18n.l(Date.current, format: :short))
        )
      end
      expect(mise_en_action.reload).to have_attributes(remediation: "autre",
                                                       precision_autre: "atelier numérique")
    end

    it "abandonne la précision quand on choisit un autre type d'aide" do
      within(".questions-remediation") do
        click_button autre
        fill_in precisez, with: "atelier numérique"
        click_button formation_metier
      end

      expect(page).to have_css("[data-reponse='true'] .tag", text: formation_metier)
      expect(mise_en_action.reload).to have_attributes(remediation: "formation_metier",
                                                       precision_autre: nil)
    end

    it "referme « Précisez » sans rien enregistrer quand on reclique sur « Autre »" do
      within(".questions-remediation") do
        click_button autre
        click_button autre

        expect(page).to have_css("button[aria-pressed='false']", text: autre)
        expect(page).to have_no_field(precisez)
        expect(page).to have_no_button(enregistrer)
      end
      expect(mise_en_action.reload.remediation).to be_nil
    end
  end

  describe "sur le détail d'une évaluation avec une réponse « Autre »" do
    before do
      create :mise_en_action, evaluation: evaluation, effectuee: true, remediation: "autre",
                              precision_autre: "atelier numérique"
      visit admin_evaluation_eva_path(evaluation)
    end

    it "retrouve « Autre » et sa précision quand on modifie la réponse" do
      within(".card__banner--illettrisme") do
        click_link I18n.t("reponse_mise_en_action.modifier")
        click_button "Oui"

        within(".questions-remediation") do
          expect(page).to have_css("button[aria-pressed='true']",
                                   text: I18n.t("activerecord.attributes.mise_en_action" \
                                                ".remediation.autre"))
          expect(page).to have_field(precisez, with: "atelier numérique")
        end
      end
    end
  end

  describe "sur le détail d'une évaluation avec une remédiation" do
    let(:accompagnement_necessaire) do
      I18n.t("activerecord.attributes.mise_en_action.difficulte.accompagnement_necessaire")
    end

    before do
      create :mise_en_action, evaluation: evaluation, effectuee: true,
                              remediation: "formation_metier"
      visit admin_evaluation_eva_path(evaluation)
    end

    it "propose de nouveau Oui et Non quand on modifie la réponse" do
      within(".card__banner--illettrisme") { click_link I18n.t("reponse_mise_en_action.modifier") }

      expect(page).to have_button("Oui")
      expect(page).to have_button("Non")
    end

    it "affiche la nouvelle qualification quand on change de réponse" do
      within(".card__banner--illettrisme") do
        click_link I18n.t("reponse_mise_en_action.modifier")
        click_button "Non"
        within(".questions-difficulte") { click_button accompagnement_necessaire }

        expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_false"))
        expect(page).to have_css("[data-reponse='false'] .tag", text: accompagnement_necessaire)
        expect(page).to have_no_content(I18n.t("reponse_mise_en_action.titre_true"))
      end
    end
  end


  describe "quand l'option « Pas encore » est active" do
    before { allow(MiseEnAction).to receive(:pas_encore_actif?).and_return(true) }

    describe "sur le détail d'une évaluation" do
      let(:pas_encore) { I18n.t("question_mise_en_action.bouton_pas_encore") }

      before { visit admin_evaluation_eva_path(evaluation) }

      it "demande quand refaire le point quand on répond « Pas encore »" do
        within(".card__banner--illettrisme") do
          click_button pas_encore

          expect(page).to have_css(".questions-date-revue", visible: :visible,
                                   text: I18n.t("date_revue_mise_en_action.question"))
          expect(page).to have_no_button(pas_encore)
        end
      end

      it "affiche la relance prévue quand on choisit de refaire le point dans 14 jours" do
        date_revue = Date.current + 14
        within(".card__banner--illettrisme") do
          click_button pas_encore
          click_button I18n.t("date_revue_mise_en_action.delais.14_jours")

          expect(page).to have_css("[data-reponse='pas_encore']", visible: :visible,
                                   text: I18n.t("reponse_mise_en_action.titre_pas_encore"))
          expect(page).to have_content(
            I18n.t("reponse_mise_en_action.relance_prevue",
                   date: I18n.l(date_revue, format: :short))
          )
        end
        expect(mise_en_action.date_revue).to eq(date_revue)
        expect(mise_en_action.choix_date_revue).to eq("14_jours")
      end

      it "affiche l'erreur et n'enregistre rien quand on choisit la date du jour" do
        within(".card__banner--illettrisme") do
          click_button pas_encore
          click_button I18n.t("date_revue_mise_en_action.choisir_une_date")
          fill_in MiseEnAction.human_attribute_name(:date_revue), with: Date.current
          click_button I18n.t("date_revue_mise_en_action.enregistrer")

          expect(page).to have_css(
            ".champ-date-revue .fr-message--error",
            text: I18n.t("activerecord.errors.models.mise_en_action.attributes" \
                         ".date_revue.a_partir_de_demain")
          )
        end
        expect(mise_en_action.date_revue).to be_nil
      end

      it "efface l'erreur quand on referme puis rouvre « Choisir une date »" do
        choisir_une_date = I18n.t("date_revue_mise_en_action.choisir_une_date")
        within(".card__banner--illettrisme") do
          click_button pas_encore
          click_button choisir_une_date
          click_button I18n.t("date_revue_mise_en_action.enregistrer")
          expect(page).to have_css(".champ-date-revue .fr-message--error")

          click_button choisir_une_date
          click_button choisir_une_date

          expect(page).to have_no_css(".champ-date-revue .fr-message--error")
        end
      end

      it "ne garde sélectionné que « Choisir une date », refermé quand on passe à un délai" do
        titre_confirmation = I18n.t("reponse_mise_en_action.titre_pas_encore")
        choisir_une_date = I18n.t("date_revue_mise_en_action.choisir_une_date")
        within(".card__banner--illettrisme") do
          click_button pas_encore
          click_button choisir_une_date
          fill_in MiseEnAction.human_attribute_name(:date_revue), with: Date.current + 30
          click_button I18n.t("date_revue_mise_en_action.enregistrer")
          expect(page).to have_content(titre_confirmation)
          click_link I18n.t("reponse_mise_en_action.modifier")
          click_button pas_encore
          expect(page).to have_css("button[aria-pressed='true']", count: 1, text: choisir_une_date)

          click_button I18n.t("date_revue_mise_en_action.delais.1_mois")
          expect(page).to have_content(titre_confirmation)
          click_link I18n.t("reponse_mise_en_action.modifier")
          click_button pas_encore

          expect(page).to have_css(".questions-date-revue", visible: :visible)
          expect(page).to have_no_field(MiseEnAction.human_attribute_name(:date_revue))
          expect(page).to have_no_css("button[aria-pressed='true']")
        end
      end

      it "affiche la relance prévue quand on choisit une date précise" do
        date_revue = Date.current + 30
        within(".card__banner--illettrisme") do
          click_button pas_encore
          click_button I18n.t("date_revue_mise_en_action.choisir_une_date")
          fill_in MiseEnAction.human_attribute_name(:date_revue), with: date_revue
          click_button I18n.t("date_revue_mise_en_action.enregistrer")

          expect(page).to have_content(
            I18n.t("reponse_mise_en_action.relance_prevue",
                   date: I18n.l(date_revue, format: :short))
          )
        end
        expect(mise_en_action.date_revue).to eq(date_revue)
        expect(mise_en_action.choix_date_revue).to eq(MiseEnAction::CHOIX_DATE_PRECISE)
      end

      context "quand la date de revue choisie est atteinte" do
        let(:repondue_le) { Date.current - 14 }

        before do
          # Il y a 14 jours, le pro a répondu "Pas encore" et choisi "Dans 14 jours"
          Timecop.freeze(repondue_le) do
            evaluation.enregistre_mise_en_action(nil)
            evaluation.mise_en_action.reporte_dans("14_jours")
          end
          visit admin_evaluation_eva_path(evaluation)
        end

        it "repose la question en rappelant la réponse « Pas encore »" do
          within(".card__banner--illettrisme") do
            expect(page).to have_content(
              I18n.t("question_mise_en_action.rappel_pas_encore",
                     date: I18n.l(repondue_le, format: :short))
            )
            expect(page).to have_button(pas_encore)
            expect(page).to have_no_content(I18n.t("reponse_mise_en_action.titre_pas_encore"))
          end
        end
      end

      context "quand le pro a choisi une date précise, puis modifie sa réponse" do
        let(:date_revue) { Date.current + 30 }

        before do
          evaluation.enregistre_mise_en_action(nil)
          evaluation.mise_en_action.reporte_dans(MiseEnAction::CHOIX_DATE_PRECISE, date_revue)
          visit admin_evaluation_eva_path(evaluation)
        end

        it "retrouve « Choisir une date » sélectionné avec sa date" do
          within(".card__banner--illettrisme") do
            click_link I18n.t("reponse_mise_en_action.modifier")
            click_button pas_encore

            expect(page).to have_css("button[aria-pressed='true']",
                                     text: I18n.t("date_revue_mise_en_action.choisir_une_date"))
            expect(page).to have_field(MiseEnAction.human_attribute_name(:date_revue),
                                       with: date_revue.iso8601)
          end
        end
      end

      context "quand le pro a reporté dans 14 jours, puis modifie sa réponse" do
        before do
          evaluation.enregistre_mise_en_action(nil)
          evaluation.mise_en_action.reporte_dans("14_jours")
          visit admin_evaluation_eva_path(evaluation)
        end

        it "ne présélectionne aucun délai, comme les choix de Oui et de Non" do
          within(".card__banner--illettrisme") do
            click_link I18n.t("reponse_mise_en_action.modifier")
            click_button pas_encore

            expect(page).to have_css(".questions-date-revue", visible: :visible)
            expect(page).to have_no_css("button[aria-pressed='true']")
          end
        end
      end

      context "quand le pro a répondu « Pas encore » sans choisir de date, puis revient" do
        before do
          evaluation.enregistre_mise_en_action(nil)
          visit admin_evaluation_eva_path(evaluation)
        end

        it "affiche seulement le choix de la date de revue" do
          within(".card__banner--illettrisme") do
            expect(page).to have_css(".questions-date-revue", visible: :visible)
            expect(page).to have_no_css("[data-reponse='pas_encore']", visible: :visible)
          end
        end
      end

      it "oublie la date précise quand on passe par Non puis revient sur « Pas encore »" do
        within(".card__banner--illettrisme") do
          click_button pas_encore
          click_button I18n.t("date_revue_mise_en_action.choisir_une_date")
          fill_in MiseEnAction.human_attribute_name(:date_revue), with: Date.current + 30
          click_button I18n.t("date_revue_mise_en_action.enregistrer")
          expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_pas_encore"))
          click_link I18n.t("reponse_mise_en_action.modifier")
          click_button I18n.t("question_mise_en_action.bouton_non")
          freins = I18n.t("activerecord.attributes.mise_en_action.difficulte.freins_peripheriques")
          within(".questions-difficulte") { click_button freins }
          expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_false"))
          click_link I18n.t("reponse_mise_en_action.modifier")
          click_button pas_encore

          expect(page).to have_css(".questions-date-revue", visible: :visible)
          expect(page).to have_no_css("button[aria-pressed='true']")
          expect(page).to have_no_field(MiseEnAction.human_attribute_name(:date_revue))
        end
      end

      it "oublie « Autre » quand on passe par « Pas encore » puis revient sur Non" do
        within(".card__banner--illettrisme") do
          click_button I18n.t("question_mise_en_action.bouton_non")
          within(".questions-difficulte") do
            click_button I18n.t("activerecord.attributes.mise_en_action.difficulte.autre")
            fill_in precisez, with: "Déménagement"
            click_button enregistrer
          end
          expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_false"))
          click_link I18n.t("reponse_mise_en_action.modifier")
          click_button pas_encore
          click_button I18n.t("date_revue_mise_en_action.delais.7_jours")
          expect(page).to have_content(I18n.t("reponse_mise_en_action.titre_pas_encore"))
          click_link I18n.t("reponse_mise_en_action.modifier")
          click_button I18n.t("question_mise_en_action.bouton_non")

          expect(page).to have_css(".questions-difficulte", visible: :visible)
          expect(page).to have_no_css("button[aria-pressed='true']")
          expect(page).to have_no_field(precisez)
        end
      end

      it "propose de nouveau les réponses quand on modifie « Pas encore »" do
        within(".card__banner--illettrisme") do
          click_button pas_encore
          click_link I18n.t("reponse_mise_en_action.modifier")

          expect(page).to have_button("Oui")
          expect(page).to have_button("Non")
          expect(page).to have_button(pas_encore)
        end
      end
    end
  end
end
