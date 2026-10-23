require "rails_helper"

RSpec.describe Beneficiaires::StatutSuivi do
  describe ".par_beneficiaire" do
    let(:beneficiaire) { create :beneficiaire }
    let(:attributs_concernee) do
      { beneficiaire: beneficiaire, synthese_competences_de_base: :illettrisme_potentiel,
        completude: "complete" }
    end

    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("DATE_STATUT_SUIVI").and_return("2026-01-01")
    end

    it "reprend le statut de sa seule évaluation concernée" do
      create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                      debutee_le: Time.zone.local(2026, 3, 1),
                                                      **attributs_concernee

      expect(described_class.par_beneficiaire([ beneficiaire.id ]))
        .to eq(beneficiaire.id => "suite_engagee")
    end

    it "reprend le statut de sa dernière évaluation concernée quand il est évalué plusieurs fois" do
      create :evaluation, :eva, :avec_mise_en_action, effectuee: true,
                                                      debutee_le: Time.zone.local(2026, 3, 1),
                                                      **attributs_concernee
      create :evaluation, :eva, debutee_le: Time.zone.local(2026, 5, 1), **attributs_concernee

      expect(described_class.par_beneficiaire([ beneficiaire.id ]))
        .to eq(beneficiaire.id => "a_renseigner")
    end

    it "ignore une évaluation plus récente non concernée" do
      create :evaluation, :eva, :avec_mise_en_action, effectuee: false,
                                                      debutee_le: Time.zone.local(2026, 3, 1),
                                                      **attributs_concernee
      create :evaluation, :eva, beneficiaire: beneficiaire,
                                synthese_competences_de_base: :socle_clea,
                                debutee_le: Time.zone.local(2026, 5, 1)

      expect(described_class.par_beneficiaire([ beneficiaire.id ]))
        .to eq(beneficiaire.id => "pas_de_suite")
    end

    it "n'est pas concerné sans évaluation concernée" do
      create :evaluation, :eva, beneficiaire: beneficiaire,
                                synthese_competences_de_base: :socle_clea,
                                debutee_le: Time.zone.local(2026, 5, 1)

      expect(described_class.par_beneficiaire([ beneficiaire.id ]))
        .to eq(beneficiaire.id => "non_concerne")
    end

    it "ignore les évaluations supprimées" do
      create :evaluation, :eva, beneficiaire: beneficiaire,
                                synthese_competences_de_base: :socle_clea,
                                debutee_le: Time.zone.local(2026, 3, 1)
      evaluation = create :evaluation, :eva, debutee_le: Time.zone.local(2026, 5, 1),
                                             **attributs_concernee
      evaluation.destroy

      expect(described_class.par_beneficiaire([ beneficiaire.id ]))
        .to eq(beneficiaire.id => "non_concerne")
    end

    it "trie les bénéficiaires dans l'ordre des statuts, les non concernés en dernier" do
      non_concerne = create :beneficiaire
      create :evaluation, :eva, beneficiaire: non_concerne,
                                synthese_competences_de_base: :socle_clea
      create :evaluation, :eva, debutee_le: Time.zone.local(2026, 5, 1), **attributs_concernee
      suite_engagee = create :beneficiaire
      create :evaluation, :eva, :avec_mise_en_action,
             effectuee: true, debutee_le: Time.zone.local(2026, 5, 1),
             **attributs_concernee, beneficiaire: suite_engagee

      expect(Beneficiaire.order(described_class.expression_rang).pluck(:id))
        .to eq [ suite_engagee.id, beneficiaire.id, non_concerne.id ]
    end

    it "ignore les évaluations Evapro" do
      create :evaluation, :evapro, debutee_le: Time.zone.local(2026, 5, 1), **attributs_concernee

      expect(described_class.par_beneficiaire([ beneficiaire.id ]))
        .to eq(beneficiaire.id => "non_concerne")
    end
  end
end
