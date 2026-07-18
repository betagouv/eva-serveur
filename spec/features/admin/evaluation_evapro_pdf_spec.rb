require 'rails_helper'
require 'pdf/reader'

describe 'Admin - Evaluation evapro PDF', type: :feature do
  before { Bullet.enable = false }

  after { Bullet.enable = true }

  let(:role) { 'admin' }
  let(:mon_compte) { create :compte, role: role }
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
      let(:pdf_fixture_path) { Rails.root.join('spec/fixtures/files/test_evaluation.pdf').to_s }
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
          Restitution::Globale,
          evaluation: evaluation_evapro,
          diag_risques_entreprise: diag_risques_entreprise,
          evaluation_impact_general: evaluation_impact_general
        )
      end

      before do
        allow(FabriqueRestitution).to receive(:restitution_globale).and_return(restitution_globale)
        allow(Pdf::Generator).to receive(:generate).and_return(pdf_fixture_path)
      end

      it 'génère une restitution Evapro en pdf' do
        visit admin_evaluation_evapro_path(evaluation_evapro, format: :pdf)

        expect(page.response_headers['Content-Type']).to include('application/pdf')
        expect(Pdf::Generator).to have_received(:generate).with(include('evaluation-evapro'))
      end
    end
  end
end
