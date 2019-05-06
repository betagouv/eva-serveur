# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Controle::Perseverance do
  let(:evaluation) { double }

  it 'lorsque la situation a été terminé: niveau 4' do
    expect(evaluation).to receive(:termine?).and_return(true)
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_4)
  end

  def self.test_nombre_bien_placee_sur_nombre_pieces(niveau, nombre_pieces, nombre_bien_placees)
    it "a abandonné après avoir bien trié #{nombre_bien_placees} biscuits
        correctement sur #{nombre_pieces}: niveau #{niveau}" do
      allow(evaluation).to receive(:termine?).and_return(false)
      allow(evaluation).to receive(:nombre_bien_placees).and_return(nombre_bien_placees)
      allow(evaluation).to receive(:evenements_pieces).and_return(Array.new(nombre_pieces))
      expect(
        described_class.new(evaluation).niveau
      ).to eql(niveau)
    end
  end

  test_nombre_bien_placee_sur_nombre_pieces(Competence::NIVEAU_1, 15, 8)
  test_nombre_bien_placee_sur_nombre_pieces(Competence::NIVEAU_INDETERMINE, 14, 8)
  test_nombre_bien_placee_sur_nombre_pieces(Competence::NIVEAU_INDETERMINE, 15, 7)
end
