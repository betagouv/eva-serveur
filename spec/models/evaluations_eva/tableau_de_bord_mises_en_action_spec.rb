require "rails_helper"

RSpec.describe EvaluationsEva::TableauDeBordMisesEnAction do
  describe "#a_renseigner" do
    let(:compte_admin) { create :compte_admin }
    let(:campagne) { create :campagne, compte: compte_admin }
    let!(:evaluation_sans_mise_en_action) do
      create :evaluation, :eva,
             synthese_competences_de_base: :illettrisme_potentiel,
             completude: "complete",
             campagne: campagne
    end
    let!(:evaluation_sans_difficulte) do
      create :evaluation, :eva, :avec_mise_en_action,
             effectuee: false,
             synthese_competences_de_base: :illettrisme_potentiel,
             campagne: campagne
    end
    let!(:evaluation_ni_ni) do
      create :evaluation, :eva, synthese_competences_de_base: :ni_ni, campagne: campagne
    end
    let!(:evaluation_sans_dispositif) do
      create :evaluation, :eva, :avec_mise_en_action,
             synthese_competences_de_base: :illettrisme_potentiel,
             campagne: campagne
    end
    let!(:evaluation_autre_compte) do
      create :evaluation, :eva, synthese_competences_de_base: :illettrisme_potentiel
    end
    let!(:evaluation_pas_encore) do
      create :evaluation, :eva, :avec_mise_en_action,
             effectuee: nil,
             synthese_competences_de_base: :illettrisme_potentiel,
             completude: "complete",
             campagne: campagne
    end

    it "retourne les évaluations du tableau de bord mises en action pour l'ability" do
      ability = Ability.new(compte_admin)
      expect(described_class.new(ability).a_renseigner.pluck(:id))
        .to contain_exactly(evaluation_sans_mise_en_action.id, evaluation_pas_encore.id)
    end
  end

  describe "personne à proposer" do
    let(:compte_admin) { create :compte_admin }
    let(:campagne) { create :campagne, compte: compte_admin }
    let(:ability) { Ability.new(compte_admin) }
    let!(:ana) do
      create :evaluation, :eva, :a_renseigner, campagne: campagne, created_at: 1.day.ago
    end
    let!(:bruno) do
      create :evaluation, :eva, :a_renseigner, campagne: campagne, created_at: 2.days.ago
    end
    let!(:chloe) do
      create :evaluation, :eva, :a_renseigner, campagne: campagne, created_at: 3.days.ago
    end

    describe "#suivante" do
      context "à l'arrivée sur le tableau de bord" do
        it "propose la première personne à renseigner" do
          expect(described_class.new(ability).suivante(apres: nil)).to eq(ana)
        end
      end

      context "quand le conseiller passe une personne" do
        it "propose la personne suivante" do
          expect(described_class.new(ability).suivante(apres: ana.id)).to eq(bruno)
        end
      end

      context "quand le conseiller passe la dernière personne" do
        it "revient à la première personne à renseigner" do
          expect(described_class.new(ability).suivante(apres: chloe.id)).to eq(ana)
        end
      end

      context "quand le conseiller vient de répondre pour une personne" do
        let!(:repondue) do
          create :evaluation, :eva, :a_renseigner, :avec_mise_en_action,
                 campagne: campagne, created_at: 36.hours.ago
        end

        it "propose la personne qui la suivait" do
          expect(described_class.new(ability).suivante(apres: repondue.id)).to eq(bruno)
        end
      end

      context "quand l'adresse désigne une personne inconnue" do
        it "propose la première personne à renseigner" do
          expect(described_class.new(ability).suivante(apres: SecureRandom.uuid)).to eq(ana)
        end
      end

      context "quand l'adresse contient un identifiant mal formé" do
        it "propose la première personne à renseigner" do
          expect(described_class.new(ability).suivante(apres: "abc")).to eq(ana)
        end
      end

      context "quand l'adresse désigne une personne d'une autre structure" do
        let(:evaluation_autre_compte) do
          create :evaluation, :eva, synthese_competences_de_base: :illettrisme_potentiel,
                                    created_at: 36.hours.ago
        end

        it "propose la première personne à renseigner" do
          expect(described_class.new(ability).suivante(apres: evaluation_autre_compte.id))
            .to eq(ana)
        end
      end
    end

    describe "#plusieurs_a_renseigner?" do
      context "avec au moins deux personnes à renseigner" do
        it "permet de passer à une autre personne" do
          expect(described_class.new(ability).plusieurs_a_renseigner?).to be(true)
        end
      end

      context "avec une seule personne à renseigner" do
        let!(:bruno) { nil }
        let!(:chloe) { nil }

        it "ne permet pas de passer à une autre personne" do
          expect(described_class.new(ability).plusieurs_a_renseigner?).to be(false)
        end
      end
    end
  end
end
