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

  describe '#persiste' do
    def verifie_enregistrement(metriques)
      expect(evaluation).to receive(:update).with(metriques: metriques)
    end

    context 'pas de restitution' do
      let(:restitutions) { [] }
      it do
        verifie_enregistrement({})
        restitution_globale.persiste
      end
    end

    context 'une restitution avec score' do
      let(:partie) { double }
      let(:restitutions) { [double(score_ccf: 12, partie: partie)] }
      it do
        allow(partie).to receive(:cote_z_metriques).and_return({ 'score_ccf' => 1.1 })
        verifie_enregistrement score_ccf: 1.1
        restitution_globale.persiste
      end
    end

    context 'fait la moyenne des scores de restitution' do
      let(:partie1) { double }
      let(:partie2) { double }
      let(:restitutions) do
        [
          double(score_ccf: 30, partie: partie1),
          double(score_ccf: 28, partie: partie2)
        ]
      end
      it do
        allow(partie1).to receive(:cote_z_metriques).and_return({ 'score_ccf' => 1.1 })
        allow(partie2).to receive(:cote_z_metriques).and_return({ 'score_ccf' => 1.2 })
        verifie_enregistrement score_ccf: 1.15
        restitution_globale.persiste
      end
    end

    context 'sépare les scores des compétences différentes' do
      let(:partie1) { double }
      let(:partie2) { double }
      let(:restitutions) do
        [
          double(score_ccf: 30, score_memorisation: 10, partie: partie1),
          double(score_numeratie: 28, partie: partie2)
        ]
      end

      it do
        allow(partie1).to receive(:cote_z_metriques).times.and_return(
          { 'score_ccf' => 1.1, 'score_memorisation' => 1.2 }
        )
        allow(partie2).to receive(:cote_z_metriques).and_return({ 'score_numeratie' => 1.3 })
        verifie_enregistrement score_ccf: 1.1, score_memorisation: 1.2, score_numeratie: 1.3
        restitution_globale.persiste
      end
    end
  end
end
