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
    end

    describe '#renseigner_qualification' do
      let(:evaluation) { create :evaluation, :eva, :avec_mise_en_action, campagne: ma_campagne }
      let(:remediation) { 'formation_metier' }
      let(:difficulte) { 'aucune_offre_formation' }
      let(:indetermine) { 'indetermine' }

      it 'peut renseigner le dispositif de remédiation' do
        patch renseigner_qualification_admin_evaluation_eva_path(evaluation),
              params: { effectuee: true, qualification: remediation }
        evaluation.reload
        expect(evaluation.mise_en_action.effectuee).to be true
        expect(evaluation.mise_en_action.remediation).to eq remediation
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
    end
  end
end
