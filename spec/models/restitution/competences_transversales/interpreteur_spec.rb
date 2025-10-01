require 'rails_helper'

describe Restitution::CompetencesTransversales::Interpreteur do
  let(:subject) { described_class.new niveaux_competences }

  context 'pas de competences à interpreter' do
    let(:niveaux_competences) { [] }

    it { expect(subject.interpretations).to eq([]) }
  end

  context 'niveau à 4' do
    let(:niveaux_competences) { [ [ Competence::COMPARAISON_TRI, 4.0 ] ] }

    it { expect(subject.interpretations).to eq([ [ Competence::COMPARAISON_TRI, 3 ] ]) }
  end

  context 'niveau entre 1 et 4 (exclus)' do
    let(:niveaux_competences) do
      [ [ Competence::COMPARAISON_TRI, 3.9 ], [ Competence::RAPIDITE, 1.1 ] ]
    end

    it do
      expect(subject.interpretations)
        .to eq([ [ Competence::COMPARAISON_TRI, 2 ], [ Competence::RAPIDITE, 2 ] ])
    end
  end

  context 'niveau à 1' do
    let(:niveaux_competences) { [ [ Competence::COMPARAISON_TRI, 1 ] ] }

    it { expect(subject.interpretations).to eq([ [ Competence::COMPARAISON_TRI, 1 ] ]) }
  end
end
