require "rails_helper"

RSpec.describe EvaluationsEva::StatutSuivi do
  describe ".par_evaluation" do
    let(:date_statut_suivi) { "2026-10-01" }
    let(:attributs_concernee) do
      {
        synthese_competences_de_base: :illettrisme_potentiel,
        completude: "complete",
        debutee_le: Time.zone.local(2026, 10, 15)
      }
    end

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DATE_STATUT_SUIVI").and_return(date_statut_suivi)
    end

    context "quand l'évaluation est concernée" do
      it "est à renseigner sans mise en action" do
        evaluation = create :evaluation, :eva, attributs_concernee

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "a_renseigner")
      end

      it "a une suite engagée quand la réponse est Oui" do
        evaluation = create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                                    **attributs_concernee

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "suite_engagee")
      end

      it "n'a pas de suite quand la réponse est Non" do
        evaluation = create :evaluation, :eva, :avec_mise_en_action, effectuee: false,
                                                                    **attributs_concernee

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "pas_de_suite")
      end

      it "est à renseigner quand la réponse est « je ne sais pas »" do
        evaluation = create :evaluation, :eva, :avec_mise_en_action, effectuee: nil,
                                                                    **attributs_concernee

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "a_renseigner")
      end

      it "suit le changement de réponse" do
        evaluation = create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                                    **attributs_concernee
        evaluation.enregistre_mise_en_action(false)

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "pas_de_suite")
      end

      it "est à renseigner quand la mise en action a été supprimée" do
        evaluation = create :evaluation, :eva, :avec_mise_en_action, **attributs_concernee
        evaluation.mise_en_action.destroy

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "a_renseigner")
      end

      it "est concernée quand elle est passée le jour de DATE_STATUT_SUIVI" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(debutee_le: Time.zone.local(2026, 10, 1, 8))

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "a_renseigner")
      end

      it "est concernée quand les compétences transversales sont incomplètes" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(
                              completude: "competences_transversales_incompletes"
                            )

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "a_renseigner")
      end
    end

    context "quand l'évaluation n'est pas concernée" do
      it "n'est pas en illettrisme potentiel" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(synthese_competences_de_base: :socle_clea)

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "non_concerne")
      end

      it "n'est en difficulté qu'en numératie" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(
                              synthese_competences_de_base: :ni_ni,
                              positionnement_niveau_numeratie: :profil1
                            )

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "non_concerne")
      end

      it "a des compétences de base incomplètes" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(completude: "competences_de_base_incompletes")

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "non_concerne")
      end

      it "a un bénéficiaire anonymisé" do
        evaluation = create :evaluation, :eva, attributs_concernee
        evaluation.beneficiaire.update(anonymise_le: Time.current)

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "non_concerne")
      end

      it "est passée avant DATE_STATUT_SUIVI, même sans réponse" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(debutee_le: Time.zone.local(2026, 9, 30))

        expect(described_class.par_evaluation([ evaluation.id ]))
          .to eq(evaluation.id => "non_concerne")
      end

      context "quand DATE_STATUT_SUIVI n'est pas définie" do
        let(:date_statut_suivi) { nil }

        it "n'est jamais concernée" do
          evaluation = create :evaluation, :eva, attributs_concernee

          expect(described_class.par_evaluation([ evaluation.id ]))
            .to eq(evaluation.id => "non_concerne")
        end
      end
    end

    it "trie les évaluations dans l'ordre des statuts, les non concernées en dernier" do
      a_renseigner = create :evaluation, :eva, attributs_concernee
      non_concerne = create :evaluation, :eva, synthese_competences_de_base: :socle_clea
      pas_de_suite = create :evaluation, :eva, :avec_mise_en_action, effectuee: false,
                                                                    **attributs_concernee
      suite_engagee = create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                                     **attributs_concernee

      expect(EvaluationEva.order(described_class.expression_rang).pluck(:id))
        .to eq [ suite_engagee.id, pas_de_suite.id, a_renseigner.id, non_concerne.id ]
    end

    it "donne le statut de plusieurs évaluations en une fois" do
      suite_engagee = create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                                     **attributs_concernee
      non_concerne = create :evaluation, :eva, synthese_competences_de_base: :socle_clea

      expect(described_class.par_evaluation([ suite_engagee.id, non_concerne.id ]))
        .to eq(suite_engagee.id => "suite_engagee", non_concerne.id => "non_concerne")
    end

    context "quand on filtre par statut" do
      let!(:a_renseigner) { create :evaluation, :eva, attributs_concernee }
      let!(:suite_engagee) do
        create :evaluation, :eva, :avec_mise_en_action, effectuee: true, **attributs_concernee
      end
      let!(:pas_de_suite) do
        create :evaluation, :eva, :avec_mise_en_action, effectuee: false, **attributs_concernee
      end
      let!(:non_concerne) do
        create :evaluation, :eva, synthese_competences_de_base: :socle_clea
      end

      it "garde les évaluations du statut choisi" do
        expect(described_class.filtre(EvaluationEva.all, [ "a_renseigner" ]))
          .to contain_exactly(a_renseigner)
      end

      it "garde les évaluations de plusieurs statuts" do
        expect(described_class.filtre(EvaluationEva.all, %w[suite_engagee pas_de_suite]))
          .to contain_exactly(suite_engagee, pas_de_suite)
      end

      it "n'affiche jamais les évaluations non concernées" do
        expect(described_class.filtre(EvaluationEva.all, %w[non_concerne a_renseigner]))
          .to contain_exactly(a_renseigner)
      end

      it "ignore les valeurs inconnues" do
        expect(described_class.filtre(EvaluationEva.all, [ "a_renseigner') OR ('1'='1" ]))
          .to be_empty
      end
    end
  end
end
