# frozen_string_literal: true

require "rails_helper"

RSpec.describe Evaluations::DiagnosticPro::BilanConsolideCalculator do
  def build_calculator(score_risque:, pourcentage_risque:, score_cout:, score_strategie:,
score_numerique:)
    risque_events = [ instance_double(Evenement, nom: "reponse",
donnees: { "score" => score_risque }) ]
    impact_events = [
      instance_double(
        Evenement,
        nom: "reponse",
        donnees: {
          "score_cout" => score_cout,
          "score_strategies" => score_strategie,
          "score_numerique" => score_numerique
        }
      )
    ]

    diag = instance_double(
      Restitution::DiagRisquesEntreprise,
      partie: instance_double(Partie, synthese: { "pourcentage_risque" => pourcentage_risque },
evenements: risque_events)
    )
    impacts = instance_double(
      Restitution::EvaluationImpactGeneral,
      partie: instance_double(Partie, evenements: impact_events)
    )

    described_class.new(diag_risques_entreprise: diag, evaluation_impact_general: impacts)
  end

  describe "#palier" do
    it "retourne A pour un score total de 41" do
      calculator = build_calculator(
        score_risque: 0,
        pourcentage_risque: 10,
        score_cout: 11,
        score_strategie: 15,
        score_numerique: 15
      )

      expect(calculator.score_total).to eq(41)
      expect(calculator.palier).to eq("A - Très bon")
    end

    it "retourne B pour un score total de 42" do
      calculator = build_calculator(
        score_risque: 0,
        pourcentage_risque: 10,
        score_cout: 12,
        score_strategie: 15,
        score_numerique: 15
      )

      expect(calculator.score_total).to eq(42)
      expect(calculator.palier).to eq("B - Bon")
    end

    it "retourne B pour un score total de 83" do
      calculator = build_calculator(
        score_risque: 0,
        pourcentage_risque: 10,
        score_cout: 30,
        score_strategie: 26,
        score_numerique: 27
      )

      expect(calculator.score_total).to eq(83)
      expect(calculator.palier).to eq("B - Bon")
    end

    it "retourne C pour un score total de 84" do
      calculator = build_calculator(
        score_risque: 0,
        pourcentage_risque: 10,
        score_cout: 30,
        score_strategie: 26,
        score_numerique: 28
      )

      expect(calculator.score_total).to eq(84)
      expect(calculator.palier).to eq("C - Moyen")
    end

    it "retourne C pour un score total de 126" do
      calculator = build_calculator(
        score_risque: 0,
        pourcentage_risque: 10,
        score_cout: 45,
        score_strategie: 38,
        score_numerique: 43
      )

      expect(calculator.score_total).to eq(126)
      expect(calculator.palier).to eq("C - Moyen")
    end

    it "retourne D pour un score total de 127" do
      calculator = build_calculator(
        score_risque: 1,
        pourcentage_risque: 10,
        score_cout: 45,
        score_strategie: 38,
        score_numerique: 43
      )

      expect(calculator.score_total).to eq(127)
      expect(calculator.palier).to eq("D - Mauvais")
    end

    it "retourne D pour un score total de 167" do
      calculator = build_calculator(
        score_risque: 33,
        pourcentage_risque: 75,
        score_cout: 50,
        score_strategie: 35,
        score_numerique: 40
      )

      expect(calculator.score_total).to eq(167)
      expect(calculator.palier).to eq("D - Mauvais")
    end

    it "met a jour le palier quand les scores d'impact augmentent" do
      baseline = build_calculator(
        score_risque: 33,
        pourcentage_risque: 75,
        score_cout: 0,
        score_strategie: 0,
        score_numerique: 0
      )
      with_impacts = build_calculator(
        score_risque: 33,
        pourcentage_risque: 75,
        score_cout: 50,
        score_strategie: 35,
        score_numerique: 40
      )

      expect(baseline.score_total).to eq(42)
      expect(baseline.palier).to eq("B - Bon")

      expect(with_impacts.score_total).to eq(167)
      expect(with_impacts.palier).to eq("D - Mauvais")
    end

    it "conserve le malus existant quand le risque atteint 75%" do
      calculator = build_calculator(
        score_risque: 33,
        pourcentage_risque: 75,
        score_cout: 0,
        score_strategie: 0,
        score_numerique: 0
      )

      expect(calculator.score_total).to eq(42)
      expect(calculator.palier).to eq("B - Bon")
    end
  end
end
