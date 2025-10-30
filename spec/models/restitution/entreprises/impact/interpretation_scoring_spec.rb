require 'rails_helper'

describe Restitution::Entreprises::Impact::InterpretationScoring do
  describe '#calcule' do
    let(:seuils) { Restitution::Entreprises::Impact::InterpretationScoring::PERFORMANCE_COLLECTIVE_PAR_SEUIL }
    let(:evenements) do
      [ build(:evenement_demarrage) ] + evenements_reponses
    end
    let(:resultat) { described_class.new.calcule(evenements, seuils) }

    context 'quand le score est entre 0 et 4' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
donnees: { question: "q1", score_cout: 0, score_numerique: 0, score_strategies: 3 }),
          build(:evenement_reponse,
donnees: { question: "q2", score_cout: 0, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q3", score_cout: 0, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q4", score_cout: 0, score_numerique: 0, score_strategies: 0 })
        ]
      end

      it "retourne faible" do
        expect(resultat).to eq(:faible)
      end
    end

    context 'quand le score est entre 5 et 9' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
donnees: { question: "q1", score_cout: 3, score_numerique: 2, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q2", score_cout: 0, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q3", score_cout: 0, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q4", score_cout: 0, score_numerique: 0, score_strategies: 0 })
        ]
      end

      it "retourne moyen" do
        expect(resultat).to eq(:moyen)
      end
    end

    context 'quand le score est entre 10 et 14' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
donnees: { question: "q1", score_cout: 3, score_numerique: 2, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q2", score_cout: 0, score_numerique: 2, score_strategies: 3 }),
          build(:evenement_reponse,
donnees: { question: "q3", score_cout: 0, score_numerique: 0, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q4", score_cout: 0, score_numerique: 0, score_strategies: 0 })
        ]
      end

      it "retourne fort" do
        expect(resultat).to eq(:fort)
      end
    end

    context 'quand le score est entre 15 et 17' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse,
donnees: { question: "q1", score_cout: 3, score_numerique: 2, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q2", score_cout: 0, score_numerique: 2, score_strategies: 3 }),
          build(:evenement_reponse,
donnees: { question: "q3", score_cout: 3, score_numerique: 2, score_strategies: 0 }),
          build(:evenement_reponse,
donnees: { question: "q4", score_cout: 0, score_numerique: 0, score_strategies: 0 })
        ]
      end

      it "retourne tres_fort" do
        expect(resultat).to eq(:tres_fort)
      end
    end
  end
end
