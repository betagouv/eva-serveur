# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Globale do
  let(:restitution_globale) do
    Restitution::Globale.new restitutions: restitutions,
                             evaluation: evaluation
  end
  let(:evaluation) { double }

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

  describe "#structure retourne le nom de la structure où a été passé l'évaluation" do
    let(:restitutions) { [double] }
    let(:structure) { double(nom: 'Mission locale modiale') }
    let(:compte) { double(structure: structure) }
    let(:campagne) { double(compte: compte) }
    let(:evaluation) { double(campagne: campagne) }
    it { expect(restitution_globale.structure).to eq('Mission locale modiale') }
  end

  describe "#structure s'il n'y a pas de structure pour le compte" do
    let(:restitutions) { [double] }
    let(:compte) { double(structure: nil) }
    let(:campagne) { double(compte: compte) }
    let(:evaluation) { double(campagne: campagne) }
    it { expect(restitution_globale.structure).to eq(nil) }
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

    context 'ignore les restitutions sans efficience' do
      let(:questions) { Restitution::Questions.new(nil, nil) }
      let(:restitutions) { [questions, double(efficience: 20)] }
      it do
        expect(questions).to_not receive(:efficience)
        expect(restitution_globale.efficience).to eq(20)
      end
      it 'ne modifie pas le tableau de restitutions' do
        expect(restitution_globale.restitutions.size).to eql(2)
        restitution_globale.efficience
        expect(restitution_globale.restitutions.size).to eql(2)
      end
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
      it do
        expect(restitution_globale.niveaux_competences)
          .to eq([[Competence::COMPARAISON_TRI, 4.0]])
      end
    end

    context 'une évaluation, deux compétences' do
      let(:restitutions) { [double(competences: niveau_comparaison.merge(niveau_rapidite))] }
      it do
        expect(restitution_globale.niveaux_competences)
          .to eq([
                   [Competence::COMPARAISON_TRI, 4.0],
                   [Competence::RAPIDITE, 4.0]
                 ])
      end
    end

    context 'deux évaluation, deux compétences différentes' do
      let(:restitution1) { double(competences: niveau_comparaison) }
      let(:restitution2) { double(competences: niveau_rapidite) }
      let(:restitutions) { [restitution1, restitution2] }
      it do
        expect(restitution_globale.niveaux_competences)
          .to eq([
                   [Competence::COMPARAISON_TRI, 4.0],
                   [Competence::RAPIDITE, 4.0]
                 ])
      end
    end

    context 'retourne les niveaux les plus forts en premier' do
      let(:niveau_faible) { { Competence::ORGANISATION_METHODE => Competence::NIVEAU_1 } }
      let(:restitution1) { double(competences: niveau_faible) }
      let(:restitution2) { double(competences: niveau_comparaison) }
      let(:restitutions) { [restitution1, restitution2] }
      it do
        expect(restitution_globale.niveaux_competences)
          .to eq([
                   [Competence::COMPARAISON_TRI, 4.0],
                   [Competence::ORGANISATION_METHODE, 1.0]
                 ])
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
        resultat = [Competence::COMPARAISON_TRI, 3.5]
        expect(restitution_globale.niveaux_competences).to eq([resultat])
      end
    end

    context "ignore les compétences inutilisées dans l'efficience" do
      let(:niveau_perseverance) { { Competence::PERSEVERANCE => Competence::NIVEAU_3 } }
      let(:restitutions) { [double(competences: niveau_perseverance)] }
      it { expect(restitution_globale.niveaux_competences).to eq([]) }
    end
  end

  describe '#interpretations_niveau1' do
    let(:restitutions) { [] }
    let(:interpretations) { restitution_globale.interpretations_niveau1 }

    before do
      allow(Restitution::Illettrisme::DetecteurIllettrisme)
        .to receive(:new).with(restitutions).and_return(detecteur_illettrisme)
    end

    context "en cas d'illettrisme potentiel" do
      let(:detecteur_illettrisme) { double(illettrisme_potentiel?: true) }

      it { expect(interpretations).to eq ['illettrisme_potentiel'] }
    end

    context 'sans illettrisme potentiel' do
      let(:detecteur_illettrisme) { double(illettrisme_potentiel?: false) }
      let(:interpreteur_niveau1) { double(interpretations: [trop: :bon]) }

      before do
        allow(Restitution::Illettrisme::InterpreteurNiveau1)
          .to receive(:new).and_return(interpreteur_niveau1)
      end

      it { expect(interpretations).to eq [trop: :bon] }
    end
  end
end
