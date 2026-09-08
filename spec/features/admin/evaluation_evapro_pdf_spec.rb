require 'rails_helper'

describe 'Admin - Evaluation evapro PDF', type: :feature do
  before { Bullet.enable = false }

  after { Bullet.enable = true }

  let(:role) { 'admin' }
  let(:structure_evapro) { create(:structure_locale, usage: AvecUsage::USAGE_EVAPRO) }
  let(:mon_compte) { create :compte, role: role, structure: structure_evapro }
  let(:parcours_type) { create :parcours_type, :competences_de_base }
  let(:ma_campagne) do
    create :campagne, compte: mon_compte, libelle: 'Paris 2019', code: 'PARIS2019',
                      parcours_type: parcours_type
  end

  describe '#show' do
    before { connecte(mon_compte) }

    context 'génération PDF Evapro' do
      let(:campagne_evapro) { create(:campagne, :avec_parcours_evapro, compte: mon_compte) }
      let(:evaluation_evapro) { create(:evaluation, :evapro, campagne: campagne_evapro) }
      let(:evenements_risque) do
        [ instance_double(Evenement, nom: "reponse", donnees: { "score" => 10 }) ]
      end
      let(:evenements_impact) do
        [
          instance_double(
            Evenement,
            nom: "reponse",
            donnees: {
              "score_cout" => 12,
              "score_strategies" => 9,
              "score_numerique" => 10
            }
          )
        ]
      end
      let(:diag_risques_entreprise) do
        instance_double(
          Restitution::DiagRisquesEntreprise,
          partie: instance_double(
            Partie,
            synthese: { 'pourcentage_risque' => 20 },
            evenements: evenements_risque
          ),
          palier: 'B - Bon'
        )
      end
      let(:evaluation_impact_general) do
        instance_double(
          Restitution::EvaluationImpactGeneral,
          partie: instance_double(Partie, evenements: evenements_impact),
          synthese: {
            performance_collective: :moyen,
            agilite_organisationnelle: :moyen,
            securite_qualite: :moyen,
            mobilite_professionnelle: :moyen,
            score_cout: :moyen,
            score_strategie: :moyen,
            score_numerique: :moyen
          }
        )
      end
      let(:restitution_globale) do
        instance_double(
          Restitution::GlobaleEvapro,
          evaluation: evaluation_evapro,
          diag_risques_entreprise: diag_risques_entreprise,
          evaluation_impact_general: evaluation_impact_general
        )
      end

      before do
        allow(FabriqueRestitution).to receive(:restitution_globale).and_return(restitution_globale)
      end

      it "enqueue la génération en tâche de fond et redirige vers la page d'attente" do
        expect do
          visit admin_evaluation_evapro_path(evaluation_evapro, format: :pdf)
        end.to have_enqueued_job(Pdf::GenerationJob).with { |_token, html_content, _nom|
          expect(html_content).to include('evaluation-evapro')
        }

        expect(page).to have_current_path(%r{/admin/pdf_generations/})
      end

      it 'répond en JSON avec le jeton pour une requête AJAX (export en ligne)' do
        page.driver.header 'X-Requested-With', 'XMLHttpRequest'

        expect do
          visit admin_evaluation_evapro_path(evaluation_evapro, format: :pdf)
        end.to have_enqueued_job(Pdf::GenerationJob)

        json = JSON.parse(page.body)
        expect(json['token']).to be_present
        expect(Pdf::GenerationToken.compte_id(json['token'])).to eq(mon_compte.id)
      end
    end
  end
end
