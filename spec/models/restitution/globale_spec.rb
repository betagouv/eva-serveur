# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Globale do
  let(:restitution_globale) do
    Restitution::Globale.new restitutions: restitutions,
                             evaluation: evaluation
  end
  let(:evaluation) { double }

  def une_restitution(nom: nil, efficience: nil, competences_mobilisees: [Competence::PERSEVERANCE])
    double(nom, efficience: efficience, competences_mobilisees: competences_mobilisees)
  end

  describe "#utilisateur retourne le nom de l'évaluation" do
    let(:restitutions) { [double] }
    let(:evaluation) { double(nom: 'Jean Bon') }
    it { expect(restitution_globale.utilisateur).to eq('Jean Bon') }
  end

  describe "#date retourne la date de l'évaluation" do
    let(:date) { 2.days.ago }
    let(:restitutions) { [double] }
    let(:evaluation) { double(created_at: date) }
    it { expect(restitution_globale.date).to eq(date) }
  end

  describe '#efficience est la moyenne des efficiences' do
    context "sans restitution c'est incalculable" do
      let(:restitutions) { [] }
      it { expect(restitution_globale.efficience).to eq(0) }
    end

    context 'une restitution: son efficience' do
      let(:restitutions) { [double(efficience: 15)] }
      it { expect(restitution_globale.efficience).to eq(15) }
    end

    context 'plusieurs restitutions : la moyenne' do
      let(:restitutions) { [double(efficience: 15), double(efficience: 20)] }
      it { expect(restitution_globale.efficience).to eq(17.5) }
    end

    context 'retourne une efficience indéterminée si une restitution est indéterminé' do
      let(:restitutions) do
        [double(efficience: 20), double(efficience: ::Restitution::Globale::NIVEAU_INDETERMINE)]
      end
      it {
        expect(restitution_globale.efficience).to eq(::Restitution::Globale::NIVEAU_INDETERMINE)
      }
    end

    context 'ignore les efficiences a nil' do
      let(:restitutions) do
        [double(efficience: 20), double(efficience: nil)]
      end
      it {
        expect(restitution_globale.efficience).to eq(20)
      }
    end

    context 'avec une seul efficience a nil, retourn indéterminée' do
      let(:restitutions) do
        [double(efficience: nil)]
      end
      it {
        expect(restitution_globale.efficience).to eq(::Restitution::Globale::NIVEAU_INDETERMINE)
      }
    end
  end

  describe '#meilleure_restitution' do
    context 'aucune restitution' do
      let(:restitutions) { [] }
      it { expect(restitution_globale.meilleure_restitution).to eq(nil) }
    end

    context 'avec une restitution efficiente' do
      let(:restitution) { une_restitution(efficience: 20) }
      let(:restitutions) { [restitution] }

      it { expect(restitution_globale.meilleure_restitution).to eq(restitution) }
    end

    context 'avec une restitution sans efficience' do
      let(:restitution) { une_restitution(efficience: Competence::NIVEAU_INDETERMINE) }
      let(:restitutions) { [restitution] }

      it { expect(restitution_globale.meilleure_restitution).to eq(nil) }
    end

    context 'avec des restitutions avec efficiences' do
      let(:restitutions) do
        [
          une_restitution(nom: 'min', efficience: 20),
          une_restitution(nom: 'max', efficience: 40)
        ]
      end

      it { expect(restitution_globale.meilleure_restitution).to eq(restitutions.last) }
    end

    context 'avec une restitution sans compétences fortes' do
      let(:restitutions) { [une_restitution(efficience: 40, competences_mobilisees: nil)] }

      it { expect(restitution_globale.meilleure_restitution).to eq(nil) }
    end
  end

  describe '#competences_meilleure_restitution' do
    context 'sans meilleure restitution' do
      let(:restitutions) { [] }
      it { expect(restitution_globale.competences_meilleure_restitution). to eq [] }
    end

    context 'avec une meilleure restitution' do
      let(:competences_mobilisees) { double }
      let(:restitutions) do
        [une_restitution(efficience: 20, competences_mobilisees: competences_mobilisees)]
      end
      it do
        expect(restitution_globale.competences_meilleure_restitution).to eq competences_mobilisees
      end
    end
  end
end
