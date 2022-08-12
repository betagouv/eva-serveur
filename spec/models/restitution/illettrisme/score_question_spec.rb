# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::ScoreQuestion do
  let(:mock_metriques_temps_questions) { double }
  let(:metrique_score_question) do
    described_class.new(mock_metriques_temps_questions)
  end

  describe '#metrique metrique_score_question' do
    it "aucun événement d'identification" do
      expect(mock_metriques_temps_questions).to receive(:calcule).and_return([])
      expect(metrique_score_question.calcule([], [])).to eq []
    end

    it 'la question Syntaxe et orthographe 1 répondu avec succès suffisament rapidement' do
      expect(mock_metriques_temps_questions).to receive(:calcule)
        .and_return([{ question: 'syntaxe_et_orthographe_1', succes: true, temps: 10.0 }])
      expect(metrique_score_question.calcule([], [])).to eq [3]
    end

    it 'la question Syntaxe et orthographe 2 répondu avec succès suffisament rapidement' do
      expect(mock_metriques_temps_questions).to receive(:calcule)
        .and_return([{ question: 'syntaxe_et_orthographe_2', succes: true, temps: 9.0 }])
      expect(metrique_score_question.calcule([], [])).to eq [3]
    end

    it 'la question Syntaxe et orthographe 1 répondu avec echec trop rapidement' do
      expect(mock_metriques_temps_questions).to receive(:calcule)
        .and_return([{ question: 'syntaxe_et_orthographe_1', succes: false, temps: 10.0 }])
      expect(metrique_score_question.calcule([], [])).to eq [-2]
    end

    it 'la question Syntaxe et orthographe 1 répondu avec echec mais très lentements' do
      expect(mock_metriques_temps_questions).to receive(:calcule)
        .and_return([{ question: 'syntaxe_et_orthographe_1', succes: false, temps: 16.0 }])
      expect(metrique_score_question.calcule([], [])).to eq [0]
    end

    it 'la question Syntaxe et orthographe 1 répondu avec echec au dessus du premier seuil' do
      expect(mock_metriques_temps_questions).to receive(:calcule)
        .and_return([{ question: 'syntaxe_et_orthographe_1', succes: false, temps: 11.0 }])
      expect(metrique_score_question.calcule([], [])).to eq [-1]
    end

    it 'la question Syntaxe et orthographe 1 répondu avec echec en dessous du second seuil' do
      expect(mock_metriques_temps_questions).to receive(:calcule)
        .and_return([{ question: 'syntaxe_et_orthographe_1', succes: false, temps: 15.0 }])
      expect(metrique_score_question.calcule([], [])).to eq [-1]
    end
  end
end
