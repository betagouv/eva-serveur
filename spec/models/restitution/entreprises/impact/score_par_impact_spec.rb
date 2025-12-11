require 'rails_helper'

describe Restitution::Entreprises::Impact::ScoreParImpact do
  describe '#calcule_score_cout' do
    let(:pourcentage_risque) { 10 }
    let(:evenements) do
      [ build(:evenement_demarrage) ] + evenements_reponses
    end
    let(:resultat) { described_class.new.calcule_score_cout(evenements, pourcentage_risque) }

    # Construit 4 évènements de réponse avec un score_cout total donné
    # le score_cout_total correspond à la somme des scores_cout de chaque évènement de réponse
    # On assigne un nombre aléatoire de 0 à score_cout_total à chaque évènement de réponse
    # La méthode doit s'assurer de ne pas dépasser le score_cout_total
    def evenements_reponses_avec_score_cout(score_cout_total)
      score_restant = score_cout_total
      evenements_reponses = []

      4.times do |index|
        score_attribue =
          if index == 3
            score_restant
          else
            rand(0..score_restant)
          end

        evenements_reponses << build(
          :evenement_reponse,
          donnees: { question: "q#{index + 1}", score_cout: score_attribue }
        )
        score_restant -= score_attribue
      end
      evenements_reponses
    end

    context 'quand le score est entre 0 et 12' do
      let(:evenements_reponses) do
        evenements_reponses_avec_score_cout(12)
      end

      it "retourne faible" do
        expect(resultat).to eq(:faible)
      end
    end

    context 'quand le score est entre 13 et 25' do
      let(:evenements_reponses) do
        evenements_reponses_avec_score_cout(13)
      end

      it "retourne moyen" do
        expect(resultat).to eq(:moyen)
      end
    end

    context 'quand le score est entre 26 et 38' do
      let(:evenements_reponses) do
        evenements_reponses_avec_score_cout(26)
      end

      it "retourne fort" do
        expect(resultat).to eq(:fort)
      end
    end

    context 'quand le score est entre 39 et 50' do
      let(:evenements_reponses) do
        evenements_reponses_avec_score_cout(39)
      end

      it "retourne tres_fort" do
        expect(resultat).to eq(:tres_fort)
      end
    end

    describe "prise en compte des malus" do
      let(:evenements_reponses) do
        evenements_reponses_avec_score_cout(12)
      end

      context 'quand le pourcentage de risque est entre 10' do
        let(:pourcentage_risque) { 10 }

        it "aucun malus ne s’applique, retourne faible" do
          expect(resultat).to eq(:faible)
        end
      end

      context 'quand le pourcentage de risque est 25' do
        let(:evenements_reponses) do
          evenements_reponses_avec_score_cout(12)
        end
        let(:pourcentage_risque) { 25 }

        it "un malus de 1 est appliqué, retourne moyen (12 + 1 = 13)" do
          expect(resultat).to eq(:moyen)
        end
      end

      context 'quand le pourcentage de risque est 50' do
        let(:evenements_reponses) do
          evenements_reponses_avec_score_cout(11)
        end
        let(:pourcentage_risque) { 50 }


        it "un malus de 2 est appliqué, retourne moyen (11 + 2 = 13)" do
          expect(resultat).to eq(:moyen)
        end
      end

      context 'quand le pourcentage de risque est 75' do
        let(:evenements_reponses) do
          evenements_reponses_avec_score_cout(10)
        end
        let(:pourcentage_risque) { 75 }

        it "un malus de 3 est appliqué, retourne moyen (10 + 3 = 13)" do
          expect(resultat).to eq(:moyen)
        end
      end
    end
  end
end
