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

    it { expect(restitution_globale.structure).to be_nil }
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
      let(:niveau_comparaison3) { { Competence::COMPARAISON_TRI => Competence::NIVEAU_3 } }
      let(:restitution1) { double(competences: niveau_comparaison) }
      let(:restitution2) { double(competences: niveau_comparaison3) }
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

  describe '#interpretations_niveau1_cefr' do
    let(:restitutions) { [] }
    let(:interpretations) { restitution_globale.interpretations_niveau1_cefr }

    context 'sans illettrisme potentiel' do
      let(:interpreteur_niveau1_cefr) { double(interpretations_cefr: [trop: :bon]) }

      before do
        allow(Restitution::Illettrisme::InterpreteurNiveau1)
          .to receive(:new).and_return(interpreteur_niveau1_cefr)
      end

      it { expect(interpretations).to eq [trop: :bon] }
    end
  end

  describe '#interpretations_niveau1_anlci' do
    let(:restitutions) { [] }
    let(:interpretations) { restitution_globale.interpretations_niveau1_anlci }

    context 'sans illettrisme potentiel' do
      let(:interpreteur_niveau1_anlci) { double(interpretations_anlci: [trop: :bon]) }

      before do
        allow(Restitution::Illettrisme::InterpreteurNiveau1)
          .to receive(:new).and_return(interpreteur_niveau1_anlci)
      end

      it { expect(interpretations).to eq [trop: :bon] }
    end
  end

  describe '#interpretations' do
    let(:restitutions) { [] }
    let(:interpreteur_niveau1) do
      double(
        synthese: 'illetrisme_potentiel',
        interpretations_cefr: { litteratie: :pre_A1, numeratie: :X1 },
        interpretations_anlci: { litteratie: :profil1, numeratie: :profil2 }
      )
    end

    it do
      allow(Restitution::Illettrisme::InterpreteurNiveau1)
        .to receive(:new).and_return(interpreteur_niveau1)
      expect(restitution_globale.interpretations)
        .to eq(
          {
            synthese_competences_de_base: 'illetrisme_potentiel',
            niveau_cefr: :pre_A1,
            niveau_cnef: :X1,
            niveau_anlci_litteratie: :profil1,
            niveau_anlci_numeratie: :profil2
          }
        )
    end
  end

  describe '#complete?' do
    let(:evaluation) { double(campagne_id: SecureRandom.uuid) }
    let(:situation1) { Situation.new id: SecureRandom.uuid }
    let(:situation2) { Situation.new id: SecureRandom.uuid }
    before do
      allow(SituationConfiguration)
        .to receive(:where).with(campagne_id: evaluation.campagne_id)
                           .and_return(double(pluck: [situation1.id, situation2.id]))
    end

    context "quand des situations n'ont pas été complétée" do
      let(:restitutions) { [] }

      it { expect(restitution_globale.complete?).to eq :incomplete }
    end

    context 'quand toutes les situations de la campagne ont été complétées' do
      let(:restitutions) do
        [
          double(situation: situation1, termine?: true),
          double(situation: situation2, termine?: true)
        ]
      end

      it { expect(restitution_globale.complete?).to eq :complete }
    end

    context "quand l'une des situations n'est pas terminée" do
      let(:restitutions) do
        [
          double(situation: situation1, termine?: true),
          double(situation: situation2, termine?: false)
        ]
      end

      it { expect(restitution_globale.complete?).to eq :incomplete }
    end

    context "quand une même situation n'est pas terminée" do
      let(:restitutions) do
        [
          double(situation: situation1, termine?: false),
          double(situation: situation1, termine?: false),
          double(situation: situation2, termine?: true)
        ]
      end

      it { expect(restitution_globale.complete?).to eq :incomplete }
    end
  end

  describe '#persiste' do
    let(:restitutions) { [] }
    let(:interpretations) { { synthese_competences_de_base: 'illetrisme_potentiel' } }

    before do
      allow(restitution_globale).to receive(:interpretations).and_return(interpretations)
      allow(restitution_globale).to receive(:complete?).and_return(:complete)
    end

    it do
      expect(evaluation).to receive(:update).with(interpretations.merge(completude: :complete))
      restitution_globale.persiste
    end
  end
end
