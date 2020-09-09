# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Illettrisme::DetecteurIllettrisme do
  let(:detecteur) { described_class.new restitutions }
  let(:restitutions) { [restitution] }
  let(:partie) { double(metriques: metriques) }
  let(:restitution) { double(partie: partie, termine?: true) }

  context 'aucune restitution' do
    let(:restitutions) { [] }
    it { expect(detecteur.illettrisme_potentiel?).to eq false }
  end

  context 'une restitution, moins de 80% de bonnes réponses' do
    let(:metriques) { { 'nombre_reponses_ccf' => 10, 'nombre_bonnes_reponses_ccf' => 7 } }
    it { expect(detecteur.illettrisme_potentiel?).to eq true }
  end

  context 'une restitution, plus de 80% de bonnes réponses' do
    let(:metriques) { { 'nombre_reponses_ccf' => 10, 'nombre_bonnes_reponses_ccf' => 8 } }
    it { expect(detecteur.illettrisme_potentiel?).to eq false }
  end

  context 'deux restitutions, plus de 80% au global' do
    let(:partie1) do
      double(metriques: { 'nombre_reponses_ccf' => 10, 'nombre_bonnes_reponses_ccf' => 0 })
    end
    let(:partie2) do
      double(metriques: { 'nombre_reponses_ccf' => 1, 'nombre_bonnes_reponses_ccf' => 1 })
    end

    let(:restitutions) do
      [double(partie: partie1, termine?: true), double(partie: partie2, termine?: true)]
    end

    it { expect(detecteur.illettrisme_potentiel?).to eq true }
  end

  context 'sait aussi compter les syntaxe et orthographe' do
    let(:metriques) do
      { 'nombre_reponses_syntaxe_orthographe' => 10,
        'nombre_bonnes_reponses_syntaxe_orthographe' => 7 }
    end
    it { expect(detecteur.illettrisme_potentiel?).to eq true }
  end

  context 'ignore les situations qui ne nous intéressent pas dans le calcul' do
    let(:metriques) { { 'on-s-en-fiche' => 42 } }

    it { expect(detecteur.illettrisme_potentiel?).to eq false }
  end

  context 'utilise à la fois ccf et syntaxe orthographe' do
    let(:metriques) do
      { 'nombre_bonnes_reponses_ccf' => 7,
        'nombre_reponses_ccf' => 10,
        'nombre_bonnes_reponses_syntaxe_orthographe' => 10,
        'nombre_reponses_syntaxe_orthographe' => 10 }
    end
    it { expect(detecteur.illettrisme_potentiel?).to eq false }
  end

  context 'ignore les parties non teminées' do
    let(:restitution) { double(metriques: metriques, termine?: false) }
    let(:metriques) do
      { 'nombre_reponses_syntaxe_orthographe' => 1,
        'nombre_bonnes_reponses_syntaxe_orthographe' => 0 }
    end

    it { expect(detecteur.illettrisme_potentiel?).to eq false }
  end
end
