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
end
