# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Base do
  let(:evenements)  { [] }
  let(:campagne)    { build(:campagne) }
  let(:restitution) { described_class.new(campagne, evenements) }
  let(:evaluation)  { create :evaluation }
  let(:situation)   { create :situation_inventaire }
  let!(:partie) { create :partie, evaluation: evaluation, situation: situation }

  context 'lorsque le dernier événement est stop' do
    let!(:evenements) do
      [
        create(:evenement_piece_bien_placee, partie: partie),
        create(:evenement_piece_mal_placee, partie: partie),
        create(:evenement_abandon, partie: partie)
      ]
    end

    it { expect(restitution.abandon?).to be(true) }
  end

  context 'renvoie le nombre de réécoute de la consigne' do
    let(:evenements) do
      [
        build(:evenement_demarrage),
        build(:evenement_rejoue_consigne),
        build(:evenement_rejoue_consigne)
      ]
    end

    it { expect(restitution.nombre_rejoue_consigne).to be(2) }
  end

  context "avec une liste d'au moins un événement" do
    let(:evenements) { [ build(:evenement_demarrage, partie: partie) ] }

    it "renvoie l'évaluation associée" do
      expect(restitution.evaluation).to eql(evaluation)
    end

    it 'renvoie le session_id' do
      expect(restitution.session_id).to eql(partie.session_id)
    end

    it 'renvoie la partie' do
      expect(restitution.partie).to eql(partie)
    end
  end

  context 'renvoie par défaut une liste vide pour les compétences évaluées' do
    it { expect(restitution.competences).to eql({}) }
  end

  describe '#termine?' do
    context "retourne true lorsque l'événement de fin est trouvé" do
      let(:evenements) do
        [
          build(:evenement_demarrage),
          build(:evenement_fin_situation)
        ]
      end

      it { expect(restitution.termine?).to be true }
    end

    context "retourne false lorsque l'événement de fin n'est pas trouvé" do
      let(:evenements) { [ build(:evenement_demarrage) ] }

      it { expect(described_class.new(campagne, evenements).termine?).to be false }
    end
  end

  describe '#efficience' do
    it "retourne l'efficience sans les compétences persévérance et compréhension consigne" do
      expect(restitution).to receive(:competences).and_return(
        Competence::PERSEVERANCE => Competence::NIVEAU_1,
        Competence::COMPREHENSION_CONSIGNE => Competence::NIVEAU_1,
        Competence::RAPIDITE => Competence::NIVEAU_3,
        Competence::COMPARAISON_TRI => Competence::NIVEAU_4,
        Competence::ATTENTION_CONCENTRATION => Competence::NIVEAU_4
      )
      expect(restitution.efficience).to be(91)
    end

    it 'retourne une efficience indéterminé si une compétences indéterminé' do
      expect(restitution).to receive(:competences).and_return(
        Competence::RAPIDITE => Competence::NIVEAU_1,
        Competence::COMPARAISON_TRI => Competence::NIVEAU_INDETERMINE,
        Competence::ATTENTION_CONCENTRATION => Competence::NIVEAU_2
      )
      expect(restitution.efficience).to eql(Competence::NIVEAU_INDETERMINE)
    end

    it "retourne 0 lorsque rien n'a été mesuré" do
      expect(restitution).to receive(:competences).and_return({})
      expect(restitution.efficience).to be(0)
    end
  end

  describe '#score' do
    it 'renvoie nil par défaut' do
      expect(restitution.score).to be_nil
    end
  end
end
