require 'rails_helper'

RSpec.describe Situation, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of :nom_technique }
  it { is_expected.to delegate_method(:livraison_sans_redaction?).to(:questionnaire).allow_nil }

  describe '#nom_technique_ne_doit_pas_contenir_de_tirets' do
    subject { described_class.new }

    context 'quand le nom_technique contient des tirets' do
      before { subject.nom_technique = 'nom-technique-errone' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:nom_technique]).to include("ne doit pas contenir de tirets")
      end
    end

    context 'quand le nom_technique ne contient pas de tiret' do
      before { subject.nom_technique = 'nom_technique_correct' }

      it 'is valid' do
        expect(subject.errors[:nom_technique]).to eq []
      end
    end
  end
end
