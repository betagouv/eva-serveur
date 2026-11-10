require 'rails_helper'

describe EvaluationEva do
  it { is_expected.to belong_to(:responsable_suivi).optional }
  it { is_expected.to have_one :donnee_sociodemographique }

  describe 'scopes' do
    describe '.mise_en_action_a_renseigner' do
      context "quand le pro n'a jamais répondu" do
        let!(:evaluation_sans_reponse) { create :evaluation, :eva }

        it "la mise en action est à renseigner" do
          expect(described_class.mise_en_action_a_renseigner).to include(evaluation_sans_reponse)
        end
      end

      context "quand le pro a répondu Oui" do
        let!(:evaluation_oui) { create :evaluation, :eva, :avec_mise_en_action, effectuee: true }

        it "la mise en action n'est pas à renseigner" do
          expect(described_class.mise_en_action_a_renseigner).not_to include(evaluation_oui)
        end
      end

      context "quand le pro a répondu Pas encore sans avoir choisi de date de revue" do
        let!(:evaluation_sans_date) do
          create :evaluation, :eva, :avec_mise_en_action, effectuee: nil
        end

        it "la mise en action est à renseigner" do
          expect(described_class.mise_en_action_a_renseigner).to include(evaluation_sans_date)
        end
      end

      context "quand le pro a répondu Pas encore avec une date de revue dans le futur" do
        let!(:evaluation_reportee) { create :evaluation, :eva }

        before do
          create :mise_en_action, evaluation: evaluation_reportee, effectuee: nil,
                                  date_revue: Date.current + 7
        end

        it "la mise en action n'est pas à renseigner avant la date de revue" do
          expect(described_class.mise_en_action_a_renseigner).not_to include(evaluation_reportee)
        end
      end

      context "quand le pro a répondu Pas encore et que la date de revue est aujourd'hui" do
        let(:date_revue) { Date.current }
        let!(:evaluation_a_revoir) { create :evaluation, :eva }

        before do
          # La date de revue a été choisie une semaine avant, quand elle était dans le futur
          Timecop.freeze(date_revue - 7) do
            create :mise_en_action, evaluation: evaluation_a_revoir, effectuee: nil,
                                    date_revue: date_revue
          end
        end

        it "la mise en action est de nouveau à renseigner" do
          expect(described_class.mise_en_action_a_renseigner).to include(evaluation_a_revoir)
        end
      end
    end

    describe '.competences_de_base_completes' do
      let!(:evaluation_complete) { create :evaluation, :eva, completude: 'complete' }
      let!(:evaluation_incomplete) { create :evaluation, :eva, completude: 'incomplete' }
      let!(:evaluation_transversales_incompletes) do
        create :evaluation, :eva, completude: 'competences_transversales_incompletes'
      end

      it do
        expect(described_class.competences_de_base_completes).to contain_exactly(
          evaluation_transversales_incompletes,
          evaluation_complete
        )
      end
    end

    describe ".diagnostic" do
      let!(:evaluation_diagnostic) { create(:evaluation, :eva, :diagnostic) }
      let!(:evaluation_positionnement) { create(:evaluation, :eva, :positionnement) }
      let!(:evaluation_evapro) { create(:evaluation, :eva, :avec_parcours_evapro) }

      it "retourne uniquement les évaluations du programme diagnostic (hors Eva Pro)" do
        resultats = described_class.diagnostic

        expect(resultats).to include(evaluation_diagnostic)
        expect(resultats).not_to include(evaluation_positionnement)
        expect(resultats).not_to include(evaluation_evapro)
      end
    end

    describe ".positionnement" do
      let!(:evaluation_diagnostic) { create(:evaluation, :eva, :diagnostic) }
      let!(:evaluation_positionnement) { create(:evaluation, :eva, :positionnement) }
      let!(:evaluation_evapro) { create(:evaluation, :eva, :avec_parcours_evapro) }

      it "retourne uniquement les évaluations du programme positionnement" do
        resultats = described_class.positionnement

        expect(resultats).to include(evaluation_positionnement)
        expect(resultats).not_to include(evaluation_diagnostic)
        expect(resultats).not_to include(evaluation_evapro)
      end
    end
  end

  describe '#responsables_suivi' do
    let!(:structure) { create :structure }
    let!(:structure2) { create :structure }
    let!(:compte1) { create :compte, structure: structure }
    let!(:compte2) { create :compte, structure: structure }
    let!(:compte_en_attente) { create :compte_conseiller, :en_attente, structure: structure }
    let!(:compte_refusee) { create :compte_conseiller, :refusee, structure: structure }
    let!(:compte_autre_structure) { create :compte, structure: structure2 }
    let!(:campagne) { create :campagne, compte: compte1 }
    let(:evaluation) { build :evaluation, :eva, campagne: campagne }

    it "retourne les responsables de suivi possible pour l'évaluation" do
      expect(evaluation.responsables_suivi).to contain_exactly(compte1, compte2)
    end
  end

  describe "#enregistre_mise_en_action" do
    let(:date_du_jour) { Time.zone.local(2023, 1, 1, 12, 0, 0) }

    context "quand il y a une mise en action associée" do
      let!(:evaluation) { create :evaluation, :eva, :avec_mise_en_action, effectuee: true }

      it "enregistre la réponse sur la mise en action existante, sans en créer une autre" do
        expect { evaluation.enregistre_mise_en_action(false) }
          .not_to change(MiseEnAction, :count)

        expect(evaluation.mise_en_action.reload.effectuee).to be(false)
      end
    end

    context "quand il n'y a pas de mise en action associée" do
      let!(:evaluation) { create :evaluation, :eva }

      it "crée et enregistre une réponse true" do
        Timecop.freeze(date_du_jour) do
          evaluation.enregistre_mise_en_action(true)
        end

        expect(evaluation.mise_en_action.effectuee).to be(true)
        expect(evaluation.mise_en_action.repondue_le).to eq(date_du_jour)
      end

      it "crée et enregistre une réponse false" do
        Timecop.freeze(date_du_jour) do
          evaluation.enregistre_mise_en_action(false)
        end

        expect(evaluation.mise_en_action.effectuee).to be(false)
        expect(evaluation.mise_en_action.repondue_le).to eq(date_du_jour)
      end

      it "retient le compte qui a répondu" do
        compte = create(:compte)
        evaluation.enregistre_mise_en_action(true, compte: compte)

        expect(evaluation.mise_en_action.repondue_par).to eq(compte)
      end
    end

    context "quand le pro modifie sa réponse" do
      let!(:evaluation) { create :evaluation, :eva, :avec_mise_en_action, effectuee: true }
      let(:precedente) { evaluation.mise_en_action }

      it "conserve la précédente en la marquant remplacée" do
        precedente
        expect { evaluation.enregistre_mise_en_action(false, modification: true) }
          .to change(MiseEnAction, :count).by(1)

        expect(precedente.reload.remplacee_le).to be_present
        expect(evaluation.mise_en_action.effectuee).to be(false)
        expect(evaluation.mise_en_action.remplacee_le).to be_nil
      end
    end
  end

  describe "#mise_en_action" do
    let(:structure) { create(:structure_locale) }
    let(:campagne) { create(:campagne, compte: create(:compte, structure: structure)) }
    let(:beneficiaire) { create(:beneficiaire) }
    let!(:premiere) do
      create :evaluation, :eva, campagne: campagne, beneficiaire: beneficiaire,
                                debutee_le: "2026-02-10"
    end
    let!(:seconde) do
      create :evaluation, :eva, campagne: campagne, beneficiaire: beneficiaire,
                                debutee_le: "2026-04-28"
    end

    it "vaut pour les autres évaluations de la personne dans la même structure" do
      premiere.enregistre_mise_en_action(true)

      expect(seconde.mise_en_action).to eq(premiere.mise_en_action)
    end

    it "ne vaut pas dans une autre structure" do
      premiere.enregistre_mise_en_action(true)
      autre_campagne = create(:campagne, compte: create(:compte,
                                                        structure: create(:structure_locale)))
      ailleurs = create :evaluation, :eva, campagne: autre_campagne, beneficiaire: beneficiaire

      expect(ailleurs.mise_en_action).to be_nil
    end

    it "ignore une déclaration remplacée" do
      premiere.enregistre_mise_en_action(true)
      premiere.mise_en_action.remplace!

      expect(seconde.mise_en_action).to be_nil
    end
  end
end
