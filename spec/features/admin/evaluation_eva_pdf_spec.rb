require 'rails_helper'

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
            Restitution::GlobaleEva,
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
          allow(restitution_globale).to receive(:selectionne_derniere_restitution)
          allow(FabriqueRestitution).to receive(:restitution_globale)
            .and_return(restitution_globale)
        end

        describe 'génération PDF' do
          it "enqueue la génération en tâche de fond et redirige vers la page d'attente" do
            expect do
              visit admin_evaluation_eva_path(mon_evaluation, format: :pdf)
            end.to have_enqueued_job(Pdf::GenerationJob)

            expect(page).to have_current_path(%r{/admin/pdf_generations/})
          end

          it 'répond en JSON avec le jeton pour une requête AJAX (export en ligne)' do
            page.driver.header 'X-Requested-With', 'XMLHttpRequest'

            expect do
              visit admin_evaluation_eva_path(mon_evaluation, format: :pdf)
            end.to have_enqueued_job(Pdf::GenerationJob)

            json = JSON.parse(page.body)
            expect(json['token']).to be_present
            expect(Pdf::GenerationToken.compte_id(json['token'])).to eq(mon_compte.id)
          end
        end
      end
    end
  end
end
