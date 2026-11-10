require 'rails_helper'

describe 'Evaluation eva', type: :request do
  describe 'member_action' do
    let(:mon_compte) { create :compte, role: 'admin' }
    let(:ma_campagne) { create :campagne, compte: mon_compte }

    before do
      sign_in mon_compte
    end

    describe "#ajouter_responsable_suivi" do
      let(:mon_collegue) { create :compte_conseiller, structure: mon_compte.structure }
      let(:evaluation) { create :evaluation, :eva, campagne: ma_campagne }

      it "peut ajouter un responsable de suivi" do
        expect do
          post ajouter_responsable_suivi_admin_evaluation_eva_path(evaluation),
               params: { responsable_suivi_id: mon_collegue.id }
        end.to change { evaluation.reload.responsable_suivi }
           .from(nil)
          .to(mon_collegue)
      end

      it "ne fait rien si le responsable de suivi n'existe pas" do
        expect do
          post ajouter_responsable_suivi_admin_evaluation_eva_path(evaluation),
               params: { responsable_suivi_id: nil }
        end.not_to(change { evaluation.reload.responsable_suivi })
      end
    end

    describe '#mise_en_action' do
      let!(:evaluation) { create :evaluation, :eva, :avec_mise_en_action, campagne: ma_campagne }

      it "enregistre la mise en action non effectuee alors qu'elle l'était avec une remediation" do
        evaluation.mise_en_action.update(remediation: :formation_metier)

        expect do
          put mise_en_action_admin_evaluation_eva_path(evaluation),
              params: { mise_en_action_effectuee: false }
        end.not_to change(MiseEnAction, :count)

        mise_en_action = evaluation.reload.mise_en_action
        expect(mise_en_action.effectuee).to be false
        expect(mise_en_action.repondue_le).not_to be_nil
        expect(mise_en_action.remediation).to be_nil
      end

      context "quand on répond « Pas encore »" do
        let(:reponse) { { mise_en_action_effectuee: MiseEnAction::REPONSE_PAS_ENCORE } }

        before { Bullet.enable = false }

        after { Bullet.enable = true }

        it "enregistre la réponse, sans motif ni date de revue, quand l'option est active" do
          allow(MiseEnAction).to receive(:pas_encore_actif?).and_return(true)

          put mise_en_action_admin_evaluation_eva_path(evaluation), params: reponse

          expect(response).to have_http_status(:no_content)
          mise_en_action = evaluation.reload.mise_en_action
          expect(mise_en_action.effectuee).to be_nil
          expect(mise_en_action.motif).to be_nil
          expect(mise_en_action.date_revue).to be_nil
          expect(mise_en_action.repondue_le).not_to be_nil
        end

        it "refuse la réponse quand l'option n'est pas active" do
          allow(MiseEnAction).to receive(:pas_encore_actif?).and_return(false)

          put mise_en_action_admin_evaluation_eva_path(evaluation), params: reponse

          expect(response).to have_http_status(:unprocessable_content)
          expect(evaluation.reload.mise_en_action.effectuee).to be(true)
        end
      end
    end

    describe '#renseigner_qualification' do
      let(:evaluation) { create :evaluation, :eva, :avec_mise_en_action, campagne: ma_campagne }
      let(:remediation) { 'formation_metier' }
      let(:difficulte) { 'aucune_offre_formation' }
      let(:indetermine) { 'indetermine' }

      before { Bullet.enable = false }

      after { Bullet.enable = true }

      it 'peut renseigner le dispositif de remédiation' do
        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: true, qualification: remediation }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be true
        expect(evaluation.mise_en_action.remediation).to eq remediation
      end

      it "renvoie la qualification et la date de réponse à afficher" do
        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: true, qualification: remediation }

        expect(response.parsed_body).to eq(
          "qualification" => I18n.t("activerecord.attributes.mise_en_action.remediation" \
                                    ".formation_metier"),
          "repondue_le" => I18n.t("reponse_mise_en_action.repondue_le", date: "01/01/2023",
                                  auteur: "", origine: "")
        )
      end

      it 'peut ignorer le dispositif de remédiation' do
        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: true, qualification: indetermine }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be true
        expect(evaluation.mise_en_action.remediation).to eq indetermine
      end

      it 'peut renseigner une difficultée' do
        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: false, qualification: difficulte }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be false
        expect(evaluation.mise_en_action.difficulte).to eq difficulte
      end

      it 'peut ignorer la difficultée' do
        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: false, qualification: indetermine }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be false
        expect(evaluation.mise_en_action.difficulte).to eq indetermine
      end

      it "enregistre une réponse « Autre » avec sa précision" do
        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: false, qualification: "autre",
                        precision_autre: "déménagement prévu le mois prochain" }

        expect(response).to have_http_status(:ok)
        mise_en_action = evaluation.mise_en_action.reload
        expect(mise_en_action.difficulte).to eq "autre"
        expect(mise_en_action.precision_autre).to eq "déménagement prévu le mois prochain"
      end

      it "refuse une réponse « Autre » sans précision et renvoie le message d'erreur" do
        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: true, qualification: "autre", precision_autre: "   " }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body).to eq(
          "erreur" => I18n.t("activerecord.errors.models.mise_en_action.attributes" \
                             ".precision_autre.blank_remediation")
        )
        expect(evaluation.mise_en_action.reload.remediation).to be_nil
      end

      it "refuse une qualification incohérente avec la réponse" do
        evaluation.mise_en_action.update!(effectuee: false, difficulte: difficulte)

        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: true, qualification: remediation }

        expect(response).to have_http_status(:unprocessable_content)
        expect(evaluation.mise_en_action.reload.effectuee).to be false
      end
    end

    describe "#renseigner_date_revue" do
      let(:evaluation) do
        create :evaluation, :eva, :avec_mise_en_action, effectuee: nil, campagne: ma_campagne
      end

      before { Bullet.enable = false }

      after { Bullet.enable = true }

      context "quand le pro choisit « Dans 14 jours »" do
        it "enregistre la date de revue et son choix, renvoie la relance et la date de réponse" do
          date_revue = Date.current + 14

          patch renseigner_date_revue_admin_evaluation_eva_path(evaluation),
                params: { choix_date_revue: "14_jours" }

          mise_en_action = evaluation.mise_en_action.reload
          expect(mise_en_action.date_revue).to eq(date_revue)
          expect(mise_en_action.choix_date_revue).to eq("14_jours")
          expect(response.parsed_body).to eq(
            "relance_prevue" => I18n.t("reponse_mise_en_action.relance_prevue",
                                       date: I18n.l(date_revue, format: :short)),
            "repondue_le" => I18n.t("reponse_mise_en_action.repondue_le", date: "01/01/2023",
                                  auteur: "", origine: "")
          )
        end
      end

      context "quand le pro choisit une date précise aujourd'hui" do
        it "refuse la date et renvoie le message d'erreur" do
          patch renseigner_date_revue_admin_evaluation_eva_path(evaluation),
                params: { date_revue: Date.current.iso8601,
                          choix_date_revue: MiseEnAction::CHOIX_DATE_PRECISE }

          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body).to eq(
            "erreur" => I18n.t("activerecord.errors.models.mise_en_action.attributes" \
                               ".date_revue.a_partir_de_demain")
          )
        end
      end
    end
  end
end
