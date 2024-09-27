# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Competence::ProfilEvacob do
  let(:restitution) { double }
  let(:partie) { double }
  let(:competence_lecture_bas) { described_class.new(restitution, 'score_lecture') }

  before do
    allow(restitution).to receive(:partie).and_return(partie)
  end

  context 'sans abandon' do
    before do
      allow(restitution).to receive(:abandon?).and_return(false)
    end

    it "n'a pas de score de lecture" do
      expect(partie).to receive(:metriques).and_return({})
      expect(
        competence_lecture_bas.niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end

    it 'a le niveau 1' do
      expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 6 })
      expect(competence_lecture_bas.niveau).to be(:profil1)
    end

    it 'a le niveau 2 bas' do
      expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 7 })
      expect(competence_lecture_bas.niveau).to be(:profil2)
    end

    it 'a le niveau 2 haut' do
      expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 10 })
      expect(competence_lecture_bas.niveau).to be(:profil2)
    end

    it 'a le niveau 3 bas' do
      expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 11 })
      expect(competence_lecture_bas.niveau).to be(:profil3)
    end

    it 'a le niveau 3 haut' do
      expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 14 })
      expect(competence_lecture_bas.niveau).to be(:profil3)
    end

    it 'a le niveau 4' do
      expect(partie).to receive(:metriques).and_return({ 'score_lecture' => 15 })
      expect(competence_lecture_bas.niveau).to be(:profil4)
    end
  end

  context 'avec abandon' do
    it 'a le niveau indéfini' do
      expect(restitution).to receive(:abandon?).and_return(true)
      expect(
        competence_lecture_bas.niveau
      ).to eql(Competence::NIVEAU_INDETERMINE)
    end
  end
end
