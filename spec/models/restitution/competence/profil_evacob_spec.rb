# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Competence::ProfilEvacob do
  let(:restitution) { double }
  let(:partie) { double }
  let(:evenements) { [] }
  let(:metrique) { 'score_lecture' }
  let(:profil_evacob) { described_class.new(restitution, metrique) }

  before do
    allow(restitution).to receive(:partie).and_return(partie)
    allow(partie).to receive(:evenements).and_return(evenements)
  end

  describe '#niveau' do
    let(:metrique) { 'score_lecture' }

    context 'sans abandon' do
      before do
        allow(restitution).to receive(:abandon?).and_return(false)
      end

      it "n'a pas de score de lecture" do
        expect(partie).to receive(:metriques).and_return({})
        expect(
          profil_evacob.niveau
        ).to eql(Competence::NIVEAU_INDETERMINE)
      end

      it 'a le niveau 1' do
        expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 6 })
        expect(profil_evacob.niveau).to be(:profil1)
      end

      it 'a le niveau 2 bas' do
        expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 7 })
        expect(profil_evacob.niveau).to be(:profil2)
      end

      it 'a le niveau 2 haut' do
        expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 10 })
        expect(profil_evacob.niveau).to be(:profil2)
      end

      it 'a le niveau 3 bas' do
        expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 11 })
        expect(profil_evacob.niveau).to be(:profil3)
      end

      it 'a le niveau 3 haut' do
        expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 14 })
        expect(profil_evacob.niveau).to be(:profil3)
      end

      it 'a le niveau 4' do
        expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 15 })
        expect(profil_evacob.niveau).to be(:profil4)
      end
    end

    context 'avec abandon' do
      it 'a le niveau indéfini' do
        expect(restitution).to receive(:abandon?).and_return(true)
        expect(
          profil_evacob.niveau
        ).to eql(Competence::NIVEAU_INDETERMINE)
      end
    end
  end

  describe '#profil_numeratie' do
    let(:metrique) { 'profil_numeratie' }

    before { allow(partie).to receive(:metriques).and_return({ metrique => 1 }) }

    context "quand le joueur n'a pas complété le niveau 1" do
      it do
        expect(
          profil_evacob.profil_numeratie
        ).to eql(Competence::NIVEAU_INDETERMINE)
      end
    end

    context 'quand le joueur a complété le niveau 1' do
      let(:derniere_question_niveau1) { 'N1Pvn4' }
      let(:evenements) { [ double(question_nom_technique: derniere_question_niveau1) ] } # rubocop:disable RSpec/VerifiedDoubles

      it do
        expect(
          profil_evacob.profil_numeratie
        ).to eql(Competence::PROFIL_1)
      end
    end
  end
end
