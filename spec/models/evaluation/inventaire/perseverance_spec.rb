# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Inventaire::Perseverance do
  NIMPORTE_QUELLE = "n'importe quelle"
  let(:evaluation) { double }

  def self.test_reussite_au_bout_d_un_temp(temp, niveau)
    it "en réussite en #{temp} : niveau #{niveau}" do
      expect(evaluation).to receive(:reussite?).and_return(true)
      expect(evaluation).to receive(:temps_total).and_return(temp.minutes.to_i)
      expect(
        described_class.new(evaluation).niveau
      ).to eql(niveau)
    end
  end

  test_reussite_au_bout_d_un_temp(23, Competence::NIVEAU_4)
  test_reussite_au_bout_d_un_temp(22, Competence::NIVEAU_INDETERMINE)

  def allow_temps_total(minutes)
    return if minutes == NIMPORTE_QUELLE

    allow(evaluation).to receive(:temps_total).and_return(minutes.minutes.to_i)
  end

  def self.message(nombre_essai_validation, minutes, nombre_erreurs, niveau)
    "abandon après #{nombre_essai_validation} essai(s) \
avec #{nombre_erreurs} erreur(s) au bout de #{minutes} minutes: niveau #{niveau}"
  end

  def self.test_non_perseverant(nombre_essai_validation,
                                minutes,
                                nombre_erreurs,
                                niveau)

    it message(nombre_essai_validation, minutes, nombre_erreurs, niveau) do
      essai = double
      allow(essai).to receive(:nombre_erreurs).and_return(nombre_erreurs)
      allow(evaluation).to receive(:essais).and_return([essai])
      expect(evaluation).to receive(:reussite?).and_return(false)
      allow_temps_total(minutes)
      allow(evaluation).to receive(:nombre_essais_validation).and_return(nombre_essai_validation)
      expect(described_class.new(evaluation).niveau)
        .to eql(niveau)
    end
  end

  test_non_perseverant(1, NIMPORTE_QUELLE,
                       "n'impote quel nombre d'", Competence::NIVEAU_1)
  test_non_perseverant(2, 21, 7, Competence::NIVEAU_1)
  test_non_perseverant(2, 21, 8, Competence::NIVEAU_INDETERMINE)
  test_non_perseverant(2, 22, 7, Competence::NIVEAU_INDETERMINE)
  test_non_perseverant(0, NIMPORTE_QUELLE,
                       "n'impote quel nombre d'", Competence::NIVEAU_INDETERMINE)
end
