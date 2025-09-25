# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Entreprises::PourcentageRisque do
  describe '#calcule' do
    let(:evenements) do
      [ build(:evenement_demarrage) ] + evenements_reponses
    end
    let(:resultat) { described_class.new.calcule(evenements) }

    context 'quand le score est entre 0 et 8' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse, donnees: { question: "q1", score: 1 }),
          build(:evenement_reponse, donnees: { question: "q2", score: 0 }),
          build(:evenement_reponse, donnees: { question: "q3", score: 1 }),
          build(:evenement_reponse, donnees: { question: "q4", score: 6 })
        ]
      end

      it "retourne 10%" do
        expect(resultat).to eq(10)
      end
    end

    context 'quand le score est entre 9 et 16' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse, donnees: { question: "q1", score: 1 }),
          build(:evenement_reponse, donnees: { question: "q2", score: 9 }),
          build(:evenement_reponse, donnees: { question: "q3", score: 6 }),
          build(:evenement_reponse, donnees: { question: "q4", score: 0 })
        ]
      end

      it "retourne 25%" do
        expect(resultat).to eq(25)
      end
    end

    context 'quand le score est entre 17 et 24' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse, donnees: { question: "q1", score: 1 }),
          build(:evenement_reponse, donnees: { question: "q2", score: 9 }),
          build(:evenement_reponse, donnees: { question: "q3", score: 10 }),
          build(:evenement_reponse, donnees: { question: "q4", score: 4 })
        ]
      end

      it "retourne 50%" do
        expect(resultat).to eq(50)
      end
    end

    context 'quand le score est entre 25 et 33' do
      let(:evenements_reponses) do
        [
          build(:evenement_reponse, donnees: { question: "q1", score: 10 }),
          build(:evenement_reponse, donnees: { question: "q2", score: 10 }),
          build(:evenement_reponse, donnees: { question: "q3", score: 10 }),
          build(:evenement_reponse, donnees: { question: "q4", score: 3 })
        ]
      end

      it "retourne 75%" do
        expect(resultat).to eq(75)
      end
    end
  end
end
