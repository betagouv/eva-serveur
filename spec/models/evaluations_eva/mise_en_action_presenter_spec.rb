require "rails_helper"

RSpec.describe EvaluationsEva::MiseEnActionPresenter do
  describe "#mise_en_action_avec_qualification?" do
    it "retourne true quand la mise en action est effectuée avec remédiation" do
      evaluation = build(:evaluation, :eva,
                         mise_en_action: build(:mise_en_action, effectuee: true,
                                                                remediation: "formation_metier"))

      presenter = described_class.new(evaluation)

      expect(presenter.effectuee_avec_remediation?).to be(true)
      expect(presenter.mise_en_action_avec_qualification?).to be(true)
    end

    it "retourne true quand la mise en action est non effectuée avec difficulté" do
      evaluation = build(:evaluation, :eva,
                         mise_en_action: build(:mise_en_action, effectuee: false,
                                                                difficulte: "freins_peripheriques"))

      presenter = described_class.new(evaluation)

      expect(presenter.non_effectuee_avec_difficulte?).to be(true)
      expect(presenter.mise_en_action_avec_qualification?).to be(true)
    end
  end

  describe "qualification ignorée depuis le tableau de bord" do
    it "laisse le type d'aide à qualifier" do
      evaluation = build(:evaluation, :eva,
                         mise_en_action: build(:mise_en_action, effectuee: true,
                                                                remediation: "indetermine"))

      presenter = described_class.new(evaluation)

      expect(presenter.effectuee_sans_remediation?).to be(true)
      expect(presenter.effectuee_avec_remediation?).to be(false)
    end

    it "laisse la raison à qualifier" do
      evaluation = build(:evaluation, :eva,
                         mise_en_action: build(:mise_en_action, effectuee: false,
                                                                difficulte: "indetermine"))

      presenter = described_class.new(evaluation)

      expect(presenter.non_effectuee_sans_difficulte?).to be(true)
      expect(presenter.non_effectuee_avec_difficulte?).to be(false)
    end
  end
end
