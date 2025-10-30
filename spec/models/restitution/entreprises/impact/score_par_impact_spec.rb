require 'rails_helper'

describe Restitution::Entreprises::Impact::ScoreParImpact do
  describe '#calcule_score_cout' do
    let(:evenements) do
      [ build(:evenement_demarrage) ] + evenements_reponses
    end
    let(:resultat) { described_class.new.calcule_score_cout(evenements) }

    context 'quand le score est entre 0 et 12' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
donnees: { question: "q1", score_cout: 10, score_numerique: 0, score_strategies: 3 }),
          build(:evenement_reponse,
donnees: { question: "q2", score_cout: 2, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q3", score_cout: 0, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q4", score_cout: 0, score_numerique: 10, score_strategies: 10 })
        ]
      end

      it "retourne faible" do
        expect(resultat).to eq(:faible)
      end
    end

    context 'quand le score est entre 13 et 25' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
donnees: { question: "q1", score_cout: 10, score_numerique: 2, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q2", score_cout: 3, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q3", score_cout: 0, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q4", score_cout: 0, score_numerique: 10, score_strategies: 10 })
        ]
      end

      it "retourne moyen" do
        expect(resultat).to eq(:moyen)
      end
    end

    context 'quand le score est entre 26 et 38' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
donnees: { question: "q1", score_cout: 10, score_numerique: 2, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q2", score_cout: 10, score_numerique: 2, score_strategies: 3 }),
          build(:evenement_reponse,
donnees: { question: "q3", score_cout: 6, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q4", score_cout: 0, score_numerique: 10, score_strategies: 10 })
        ]
      end

      it "retourne fort" do
        expect(resultat).to eq(:fort)
      end
    end

    context 'quand le score est entre 39 et 50' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
donnees: { question: "q1", score_cout: 10, score_numerique: 2, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q2", score_cout: 10, score_numerique: 2, score_strategies: 3 }),
          build(:evenement_reponse,
donnees: { question: "q3", score_cout: 10, score_numerique: 2, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q4", score_cout: 9, score_numerique: 10, score_strategies: 10 })
        ]
      end

      it "retourne tres_fort" do
        expect(resultat).to eq(:tres_fort)
      end
    end
  end
end
