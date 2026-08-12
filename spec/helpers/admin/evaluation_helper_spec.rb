require 'rails_helper'

describe Admin::EvaluationHelper do
  describe '#niveau_bas?' do
    let(:profil1) { Competence::PROFILS_BAS.first }
    let(:profil_autre) { :profil_autre }

    it 'Retourne true si le profil renseigné est un niveau bas' do
      expect(niveau_bas?(:profil1)).to be true
    end

    it "Retourne false si le profil renseigné n'est pas un niveau bas" do
      expect(niveau_bas?(:profil_autre)).to be false
    end
  end

  describe '#destroy', type: :request do
    let(:mon_compte) { create :compte, role: 'superadmin' }
    let(:campagne_evapro) { create(:campagne, :avec_parcours_evapro, compte: mon_compte) }
    let(:evaluation_evapro) do
      EvaluationEvapro.create!(campagne: campagne_evapro,
                               beneficiaire: create(:beneficiaire),
                               debutee_le: 1.hour.ago)
    end

    before do
      Bullet.enable = false
      sign_in mon_compte
    end

    after { Bullet.enable = true }

    context "quand le referer est la liste des évaluations" do
      let(:referer) { admin_evaluations_evapro_path(q: { debutee_le_gteq: "2024-01-01" }) }

      it "retourne sur le referer pour ne pas perdre les filtres" do
        delete admin_evaluation_evapro_path(evaluation_evapro),
               headers: { "HTTP_REFERER" => referer }

        expect(evaluation_evapro.reload.deleted?).to be true
        expect(response).to redirect_to(referer)
      end
    end

    context "quand le referer est la page du bénéficiaire" do
      let(:referer) { admin_beneficiaire_path(evaluation_evapro.beneficiaire) }

      it "retourne sur la page du bénéficiaire" do
        delete admin_evaluation_evapro_path(evaluation_evapro),
               headers: { "HTTP_REFERER" => referer }

        expect(evaluation_evapro.reload.deleted?).to be true
        expect(response).to redirect_to(referer)
      end
    end

    context "sans referer" do
      it "retourne sur la liste des évaluations" do
        delete admin_evaluation_evapro_path(evaluation_evapro)

        expect(evaluation_evapro.reload.deleted?).to be true
        expect(response).to redirect_to(admin_evaluations_evapro_path)
      end
    end

    context "quand le referer est la page de l'évaluation elle-même" do
      let(:referer) do
        admin_evaluation_evapro_path(
          evaluation_evapro,
          parties_selectionnees: [ SecureRandom.uuid ],
          commit: "Valider la sélection"
        )
      end

      it "redirige vers la liste" do
        delete admin_evaluation_evapro_path(evaluation_evapro),
               headers: { "HTTP_REFERER" => referer }

        expect(evaluation_evapro.reload.deleted?).to be true
        expect(response).to redirect_to(admin_evaluations_evapro_path)
      end
    end
  end
end
