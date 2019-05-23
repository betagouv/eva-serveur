# frozen_string_literal: true

require 'rails_helper'

class TestPerseverance
  def initialize(entrees, rspec)
    @rspec = rspec
    @entrees = entrees
    @entrees[:secondes] = @entrees[:minutes].minutes.to_i if @entrees[:minutes]
  end

  def message(niveau, entrees)
    message = entrees[:reussite] ? 'Réussite' : 'Abandon'
    message += " après #{entrees[:nombre_essais]} essai(s)" if entrees[:nombre_essais]
    message += " avec #{entrees[:erreurs]} erreur(s)" if entrees[:erreurs]
    message += " au bout de #{entrees[:minutes]} minutes" if entrees[:minutes]
    message + " : niveau #{niveau}"
  end

  def on_evalue_a(niveau)
    entrees = @entrees
    @rspec.it message(niveau, @entrees) do
      expect(evaluation).to receive(:reussite?).and_return(entrees[:reussite])
      essai = double
      allow(essai).to receive(:nombre_erreurs).and_return(entrees[:erreurs])
      allow(evaluation).to receive(:essais).and_return([essai])
      allow(evaluation).to receive(:nombre_essais_validation).and_return(entrees[:nombre_essais])
      allow(evaluation).to receive(:temps_total).and_return(entrees[:secondes])
      expect(described_class.new(evaluation).niveau).to eql(niveau)
    end
  end
end

describe Evaluation::Inventaire::Perseverance do
  let(:evaluation) { double }

  def self.pour(entrees)
    TestPerseverance.new(entrees, self)
  end

  pour(reussite: true, minutes: 23).on_evalue_a(Competence::NIVEAU_4)
  pour(reussite: true, minutes: 22).on_evalue_a(Competence::NIVEAU_INDETERMINE)

  pour(reussite: false, nombre_essais: 1).on_evalue_a(Competence::NIVEAU_1)
  pour(reussite: false, nombre_essais: 2, minutes: 21, erreurs: 7).on_evalue_a(Competence::NIVEAU_1)
  pour(reussite: false, nombre_essais: 2, minutes: 21, erreurs: 8)
    .on_evalue_a(Competence::NIVEAU_INDETERMINE)
  pour(reussite: false, nombre_essais: 2, minutes: 22, erreurs: 7)
    .on_evalue_a(Competence::NIVEAU_INDETERMINE)
  pour(reussite: false, nombre_essais: 0).on_evalue_a(Competence::NIVEAU_INDETERMINE)
end
