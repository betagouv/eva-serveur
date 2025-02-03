# frozen_string_literal: true

require 'rails_helper'

describe Restitution::Critere::Numeratie do
  let(:attributes) do
    {
      libelle: 'Compter, dénombrer',
      code_clea: '2.1.2',
      nombre_tests_proposes: 3,
      nombre_tests_proposes_max: 4,
      pourcentage_reussite: 50
    }
  end
  let(:critere_numeratie) { described_class.new attributes }

  it do
    expect(critere_numeratie).to have_attributes(attributes)
  end

  describe '#acquis?' do
    let(:critere) { described_class.new attributes.merge(pourcentage_reussite: pourcentage) }

    context 'quand le pourcentage de réussite est 75' do
      let(:pourcentage) { 75 }

      it { expect(critere.acquis?).to be(true) }
    end

    context 'quand le pourcentage de réussite est 74' do
      let(:pourcentage) { 74 }

      it { expect(critere.acquis?).to be(false) }
    end

    context 'quand le pourcentage de réussite est nil' do
      let(:pourcentage) { nil }

      it { expect(critere.acquis?).to be(false) }
    end
  end
end
