# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::PassationBeneficiaire::TableauDeBordMisesEnAction do
  describe ".relation" do
    let(:compte_admin) { create :compte_admin }
    let(:campagne) { create :campagne, compte: compte_admin }
    let!(:evaluation_sans_mise_en_action) do
      create :evaluation,
             synthese_competences_de_base: :illettrisme_potentiel,
             completude: "complete",
             campagne: campagne
    end
    let!(:evaluation_sans_difficulte) do
      create :evaluation, :avec_mise_en_action,
             effectuee: false,
             synthese_competences_de_base: :illettrisme_potentiel,
             campagne: campagne
    end
    let!(:evaluation_ni_ni) do
      create :evaluation, synthese_competences_de_base: :ni_ni, campagne: campagne
    end
    let!(:evaluation_sans_dispositif) do
      create :evaluation, :avec_mise_en_action,
             synthese_competences_de_base: :illettrisme_potentiel,
             campagne: campagne
    end
    let!(:evaluation_autre_compte) do
      create :evaluation, synthese_competences_de_base: :illettrisme_potentiel
    end

    it "retourne les évaluations du tableau de bord mises en action pour l'ability" do
      ability = Ability.new(compte_admin)
      expect(described_class.relation(ability).pluck(:id))
        .to eq [ evaluation_sans_mise_en_action.id ]
    end
  end
end
