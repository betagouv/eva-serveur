require "rails_helper"

RSpec.describe EvaluationsEva::StatutSuivi do
  describe ".avec_statut" do
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

    def evaluation_avec_statut(evaluation)
      described_class.avec_statut(EvaluationEva.where(id: evaluation.id)).first
    end

    def statut_de(evaluation)
      evaluation_avec_statut(evaluation).statut_suivi
    end

    context "quand l'évaluation est concernée" do
      it "est à renseigner sans mise en action" do
        evaluation = create :evaluation, :eva, attributs_concernee

        expect(statut_de(evaluation)).to eq "a_renseigner"
      end

      it "a une suite engagée quand la réponse est Oui" do
        evaluation = create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                                    **attributs_concernee

        expect(statut_de(evaluation)).to eq "suite_engagee"
      end

      it "n'a pas de suite quand la réponse est Non" do
        evaluation = create :evaluation, :eva, :avec_mise_en_action, effectuee: false,
                                                                    **attributs_concernee

        expect(statut_de(evaluation)).to eq "pas_de_suite"
      end

      it "suit le changement de réponse" do
        evaluation = create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                                    **attributs_concernee
        evaluation.enregistre_mise_en_action(false)

        expect(statut_de(evaluation)).to eq "pas_de_suite"
      end

      it "est concernée quand elle est passée le jour de DATE_STATUT_SUIVI" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(debutee_le: Time.zone.local(2026, 10, 1, 8))

        expect(statut_de(evaluation)).to eq "a_renseigner"
      end

      it "est concernée quand les compétences transversales sont incomplètes" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(
                              completude: "competences_transversales_incompletes"
                            )

        expect(statut_de(evaluation)).to eq "a_renseigner"
      end
    end

    context "quand l'évaluation n'est pas concernée" do
      it "n'est pas en illettrisme potentiel" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(synthese_competences_de_base: :socle_clea)

        expect(statut_de(evaluation)).to eq "non_concerne"
      end

      it "n'est en difficulté qu'en numératie" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(
                              synthese_competences_de_base: :ni_ni,
                              positionnement_niveau_numeratie: :profil1
                            )

        expect(statut_de(evaluation)).to eq "non_concerne"
      end

      it "a des compétences de base incomplètes" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(completude: "competences_de_base_incompletes")

        expect(statut_de(evaluation)).to eq "non_concerne"
      end

      it "a un bénéficiaire anonymisé" do
        evaluation = create :evaluation, :eva, attributs_concernee
        evaluation.beneficiaire.update(anonymise_le: Time.current)

        expect(statut_de(evaluation)).to eq "non_concerne"
      end

      it "est passée avant DATE_STATUT_SUIVI, même sans réponse" do
        evaluation = create :evaluation, :eva,
                            attributs_concernee.merge(debutee_le: Time.zone.local(2026, 9, 30))

        expect(statut_de(evaluation)).to eq "non_concerne"
      end

      context "quand DATE_STATUT_SUIVI n'est pas définie" do
        let(:date_statut_suivi) { nil }

        it "n'est jamais concernée" do
          evaluation = create :evaluation, :eva, attributs_concernee

          expect(statut_de(evaluation)).to eq "non_concerne"
        end
      end
    end

    it "donne le rang de tri de chaque statut" do
      suite_engagee = create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                                     **attributs_concernee
      pas_de_suite = create :evaluation, :eva, :avec_mise_en_action, effectuee: false,
                                                                    **attributs_concernee
      a_renseigner = create :evaluation, :eva, attributs_concernee
      non_concerne = create :evaluation, :eva, synthese_competences_de_base: :socle_clea

      rangs = [ suite_engagee, pas_de_suite, a_renseigner, non_concerne ].map do |evaluation|
        evaluation_avec_statut(evaluation).statut_suivi_rang
      end

      expect(rangs).to eq [ 1, 3, 4, 5 ]
    end
  end
end
