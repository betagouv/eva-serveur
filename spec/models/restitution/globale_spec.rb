require 'rails_helper'

describe Restitution::Globale do
  let(:restitutions) { [ double ] }
  let(:restitutions_dernier_essai) { [] }
  let(:evaluation) { double }

  let(:restitution_globale) do
    described_class.new evaluation: evaluation,
      restitutions: restitutions,
      restitutions_dernier_essai: restitutions_dernier_essai
  end

  describe "#date retourne la date de l'évaluation" do
    let(:date) { 2.days.ago }
    let(:restitutions) { [ double ] }
    let(:evaluation) { double(created_at: date) }

    it { expect(restitution_globale.date).to eq(date) }
  end

  describe "#structure retourne le nom de la structure où a été passé l'évaluation" do
    let(:restitutions) { [ double ] }
    let(:structure) { double(nom: 'Mission locale modiale') }
    let(:compte) { double(structure: structure) }
    let(:campagne) { double(compte: compte) }
    let(:evaluation) { double(campagne: campagne) }

    it { expect(restitution_globale.structure).to eq('Mission locale modiale') }
  end

  describe "#structure s'il n'y a pas de structure pour le compte" do
    let(:restitutions) { [ double ] }
    let(:compte) { double(structure: nil) }
    let(:campagne) { double(compte: compte) }
    let(:evaluation) { double(campagne: campagne) }

    it { expect(restitution_globale.structure).to be_nil }
  end

  describe '#id' do
    let(:evaluation) { double(id: 1) }

    it "retourne l'id de l'évaluation" do
      expect(restitution_globale.id).to eq 1
    end
  end
end
