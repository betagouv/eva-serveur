require 'rails_helper'
require 'pdf/reader'

describe 'Admin - Evaluation eva PDF', type: :feature do
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
               :eva,
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

            visit admin_evaluation_eva_path(mon_evaluation, format: :pdf)

            expect(page.response_headers['Content-Type']).to include('application/pdf')
          end

          it 'erreur timeout à la génération du pdf' do
            expect(Pdf::Generator).to receive(:generate).and_return(false)

            visit admin_evaluation_eva_path(mon_evaluation, format: :pdf)

            expect(page).to have_content(
              'La génération du PDF a échoué. Veuillez réessayer dans un moment'
            )
          end
        end
      end
    end
  end
end
