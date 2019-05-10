# frozen_string_literal: true

require 'rails_helper'

describe Evaluation::Inventaire::VigilanceControle do
  let(:evaluation) { double }
  let(:essai_de_prise_en_main) do
    essai = double
    allow(essai).to receive(:nombre_erreurs).and_return(8)
    allow(essai).to receive(:nombre_de_non_remplissage).and_return(7)
    essai
  end
  let(:essai_reussite) do
    essai = double
    allow(essai).to receive(:nombre_erreurs).and_return(0)
    allow(essai).to receive(:nombre_de_non_remplissage).and_return(0)
    allow(essai).to receive(:nombre_erreurs_sauf_de_non_remplissage).and_return(0)
    essai
  end

  def essai_avec_que_erreurs_de_non_remplissage(nombre_erreurs)
    essai_avec_erreurs(nombre_erreurs, nombre_erreurs)
  end

  def essai_avec_erreurs(nombre_erreurs, nombre_erreurs_de_non_remplissage = 0)
    essai = double
    allow(essai).to receive(:nombre_erreurs).and_return(nombre_erreurs)
    allow(essai).to receive(:nombre_erreurs_sauf_de_non_remplissage)
      .and_return(nombre_erreurs - nombre_erreurs_de_non_remplissage)
    allow(essai).to receive(:nombre_de_non_remplissage)
      .and_return(nombre_erreurs_de_non_remplissage)
    essai
  end

  it 'Réussite au 1er essai: niveau 4' do
    allow(evaluation).to receive(:reussite?).and_return(true)
    allow(evaluation).to receive(:nombre_essais_validation).and_return(1)
    allow(evaluation).to receive(:essais).and_return([essai_reussite])
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_4)
  end

  it 'Réussite au 2eme essai: lorsque le 1er essai comporte 7 non remplissage: niveau 4' do
    allow(evaluation).to receive(:reussite?).and_return(true)
    allow(evaluation).to receive(:nombre_essais_validation).and_return(2)
    allow(evaluation).to receive(:essais).and_return([essai_de_prise_en_main, double])
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_4)
  end

  it 'Réussite avec des essais ne comprenant que des erreurs de non remplissage: niveau 3' do
    allow(evaluation).to receive(:reussite?).and_return(true)
    allow(evaluation).to receive(:nombre_essais_validation).and_return(9)
    allow(evaluation).to receive(:essais).and_return(
      [
        essai_de_prise_en_main,
        essai_avec_que_erreurs_de_non_remplissage(7),
        essai_avec_que_erreurs_de_non_remplissage(6),
        essai_avec_que_erreurs_de_non_remplissage(5),
        essai_avec_que_erreurs_de_non_remplissage(4),
        essai_avec_que_erreurs_de_non_remplissage(3),
        essai_avec_que_erreurs_de_non_remplissage(2),
        essai_avec_que_erreurs_de_non_remplissage(1),
        essai_reussite
      ]
    )
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_3)
  end

  it 'Réussite avec 2 erreurs rectifié en 2 essais
      et autres essais avec des erreurs de non remplissage: niveau 3' do
    allow(evaluation).to receive(:reussite?).and_return(true)
    allow(evaluation).to receive(:nombre_essais_validation).and_return(6)
    allow(evaluation).to receive(:essais).and_return(
      [
        essai_de_prise_en_main,
        essai_avec_que_erreurs_de_non_remplissage(7),
        essai_avec_que_erreurs_de_non_remplissage(3),
        essai_avec_erreurs(3, 1),
        essai_avec_erreurs(2, 1),
        essai_avec_que_erreurs_de_non_remplissage(1),
        essai_reussite
      ]
    )
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_3)
  end

  it 'Réussite avec 3 erreurs rectifié en 2 essais
      et autres essais avec des erreurs de non remplissage: niveau 2' do
    allow(evaluation).to receive(:reussite?).and_return(true)
    allow(evaluation).to receive(:nombre_essais_validation).and_return(6)
    allow(evaluation).to receive(:essais).and_return(
      [
        essai_de_prise_en_main,
        essai_avec_que_erreurs_de_non_remplissage(7),
        essai_avec_que_erreurs_de_non_remplissage(3),
        essai_avec_erreurs(4, 1),
        essai_avec_erreurs(2, 1),
        essai_avec_que_erreurs_de_non_remplissage(1),
        essai_reussite
      ]
    )
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_2)
  end

  it 'Réussite au 5eme essai rectifié en 4 fois : niveau 2' do
    allow(evaluation).to receive(:reussite?).and_return(true)
    allow(evaluation).to receive(:nombre_essais_validation).and_return(5)
    allow(evaluation).to receive(:essais).and_return(
      [
        essai_de_prise_en_main,
        essai_avec_erreurs(3),
        essai_avec_erreurs(2),
        essai_avec_erreurs(1),
        essai_reussite
      ]
    )
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_2)
  end

  it 'Abandon avec 2 essais et les mêmes erreurs aux essais: niveau 1' do
    allow(evaluation).to receive(:reussite?).and_return(false)
    allow(evaluation).to receive(:abandon?).and_return(true)
    allow(evaluation).to receive(:essais).and_return(
      [
        essai_de_prise_en_main,
        essai_avec_erreurs(3),
        essai_avec_erreurs(3)
      ]
    )
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_1)
  end

  it "Abandon avec 3 essais une correction d'erreur: niveau indéterminé" do
    allow(evaluation).to receive(:reussite?).and_return(false)
    allow(evaluation).to receive(:abandon?).and_return(true)
    allow(evaluation).to receive(:essais).and_return(
      [
        essai_de_prise_en_main,
        essai_avec_erreurs(3),
        essai_avec_erreurs(3),
        essai_avec_erreurs(2)
      ]
    )
    expect(
      described_class.new(evaluation).niveau
    ).to eql(Competence::NIVEAU_INDETERMINE)
  end
end
