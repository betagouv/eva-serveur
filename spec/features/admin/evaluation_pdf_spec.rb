require 'rails_helper'
require 'pdf/reader'

describe 'Admin - Evaluation PDF', type: :feature do
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

    context 'Rôle admin' do
      let(:role) { 'admin' }
      let!(:mon_evaluation) do
        create :evaluation,
               campagne: ma_campagne,
               created_at: 3.days.ago,
               synthese_competences_de_base: :ni_ni
      end
      let(:situation) { build(:situation_inventaire) }
      let!(:partie) { create :partie, situation: situation, evaluation: mon_evaluation }
      let!(:evenement) { create :evenement_demarrage, partie: partie }
      let(:restitution) { Restitution::Inventaire.new(ma_campagne, [ evenement ]) }

      describe 'en moquant restitution_globale :' do
        let(:restitution_globale) do
          instance_double(
            Restitution::Globale,
            date: DateTime.now,
            beneficiaire: 'Roger',
            code_beneficiaire: 'ROG1234',
            restitutions: [ restitution ]
          )
        end

        before do
          competences = [ [ Competence::ORGANISATION_METHODE, Competence::NIVEAU_4 ] ]
          interpretations = [ [ Competence::ORGANISATION_METHODE, 4.0 ] ]
          allow(restitution_globale).to receive_messages(
            niveaux_competences: competences,
            interpretations_competences_transversales: interpretations,
            structure: 'structure',
            interpretations_niveau2: [],
            evaluation: mon_evaluation
          )
          allow(restitution_globale).to receive(:synthese)
          allow(restitution_globale).to receive(:synthese_diagnostic)
          allow(restitution_globale).to receive(:synthese_positionnement_litteratie)
          allow(restitution_globale).to receive(:synthese_positionnement_numeratie)
          allow(restitution_globale).to receive(:diag_risques_entreprise)
          allow(restitution_globale).to receive(:evaluation_impact_general)
          allow(restitution_globale).to receive(:selectionne_derniere_restitution)
          allow(FabriqueRestitution).to receive(:restitution_globale)
            .and_return(restitution_globale)
        end

        describe 'génération PDF' do
          let(:pdf_fixture_path) { Rails.root.join('spec/fixtures/files/test_evaluation.pdf').to_s }

          it "affiche l'évaluation en pdf" do
            allow(Pdf::Generator).to receive(:generate).and_return(pdf_fixture_path)

            visit admin_evaluation_path(mon_evaluation, format: :pdf)

            expect(page.response_headers['Content-Type']).to include('application/pdf')
          end

          it 'erreur timeout à la génération du pdf' do
            expect(Pdf::Generator).to receive(:generate).and_return(false)

            visit admin_evaluation_path(mon_evaluation, format: :pdf)

            expect(page).to have_content(
              'La génération du PDF a échoué. Veuillez réessayer dans un moment'
            )
          end
        end
      end
    end

    context 'génération PDF Evapro' do
      let(:campagne_evapro) { create(:campagne, :avec_parcours_evapro, compte: mon_compte) }
      let(:evaluation_evapro) { create(:evaluation, campagne: campagne_evapro) }
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
        visit admin_evaluation_path(evaluation_evapro, format: :pdf)

        expect(page.response_headers['Content-Type']).to include('application/pdf')
        expect(Pdf::Generator).to have_received(:generate).with(include('evaluation-evapro'))
      end
    end
  end
end
