# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Globale do
  let(:restitution_globale) do
    Restitution::Globale.new restitutions: restitutions,
                             evaluation: evaluation
  end
  let(:evaluation) { double }

  def une_restitution(nom: nil, efficience: nil)
    double(nom, efficience: efficience)
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

    context 'avec une seule efficience a nil, retourne indéterminée' do
      let(:restitutions) do
        [double(efficience: nil)]
      end
      it {
        expect(restitution_globale.efficience).to eq(::Restitution::Globale::NIVEAU_INDETERMINE)
      }
    end
  end

  describe '#niveaux_competences retournes les compétences consolidées par niveau' do
    let(:niveau_comparaison) { { Competence::COMPARAISON_TRI => Competence::NIVEAU_4 } }
    let(:niveau_rapidite) { { Competence::RAPIDITE => Competence::NIVEAU_4 } }

    context 'aucune évaluation' do
      let(:restitutions) { [] }
      it { expect(restitution_globale.niveaux_competences).to eq([]) }
    end

    context 'une évaluation, une compétences' do
      let(:restitutions) { [double(competences: niveau_comparaison)] }
      it { expect(restitution_globale.niveaux_competences).to eq([niveau_comparaison]) }
    end

    context 'une évaluation, deux compétences' do
      let(:restitutions) { [double(competences: niveau_comparaison.merge(niveau_rapidite))] }
      it do
        expect(restitution_globale.niveaux_competences)
          .to eq([niveau_comparaison, niveau_rapidite])
      end
    end

    context 'deux évaluation, deux compétences différentes' do
      let(:restitution1) { double(competences: niveau_comparaison) }
      let(:restitution2) { double(competences: niveau_rapidite) }
      let(:restitutions) { [restitution1, restitution2] }
      it do
        expect(restitution_globale.niveaux_competences)
          .to eq([niveau_comparaison, niveau_rapidite])
      end
    end

    context 'retourne les niveaux les plus forts en premier' do
      let(:niveau_faible) { { Competence::ORGANISATION_METHODE => Competence::NIVEAU_1 } }
      let(:restitution1) { double(competences: niveau_faible) }
      let(:restitution2) { double(competences: niveau_comparaison) }
      let(:restitutions) { [restitution1, restitution2] }
      it do
        expect(restitution_globale.niveaux_competences)
          .to eq([niveau_comparaison, niveau_faible])
      end
    end

    context 'ignore les niveaux indéterminées' do
      let(:niveau_indetermine) { { Competence::COMPARAISON_TRI => Competence::NIVEAU_INDETERMINE } }
      let(:restitutions) { [double(competences: niveau_indetermine)] }
      it { expect(restitution_globale.niveaux_competences).to eq([]) }
    end

    context 'fait la moyenne des niveaux' do
      let(:niveau_comparaison_3) { { Competence::COMPARAISON_TRI => Competence::NIVEAU_3 } }
      let(:restitution1) { double(competences: niveau_comparaison) }
      let(:restitution2) { double(competences: niveau_comparaison_3) }
      let(:restitutions) { [restitution1, restitution2] }
      it do
        resultat = { Competence::COMPARAISON_TRI => 3.5 }
        expect(restitution_globale.niveaux_competences).to eq([resultat])
      end
    end

    context "ignore les compétences inutilisées dans l'efficience" do
      let(:niveau_perseverance) { { Competence::PERSEVERANCE => Competence::NIVEAU_3 } }
      let(:restitutions) { [double(competences: niveau_perseverance)] }
      it { expect(restitution_globale.niveaux_competences).to eq([]) }
    end
  end
end
