# frozen_string_literal: true

require 'rails_helper'

describe Restitution::StandardisateurFige do
  let(:standards) do
    {
      ccf: { moyenne: 12, ecart_type: 3 },
      syntaxe: { moyenne: 2, ecart_type: 0.5 }
    }
  end
  let(:subject) { described_class.new standards }

  it { expect(subject.moyennes_metriques).to eq({ ccf: 12, syntaxe: 2 }) }

  it { expect(subject.ecarts_types_metriques).to eq({ ccf: 3, syntaxe: 0.5 }) }

  it { expect(subject.standardise(:ccf, 12 + 3)).to eq 1 }
end
