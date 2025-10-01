require 'rails_helper'

describe Restitution::StandardisateurFige do
  let(:standards) do
    {
      ccf: { average: 12, stddev_pop: 3 },
      syntaxe: { average: 2, stddev_pop: 0.5 }
    }
  end
  let(:subject) { described_class.new standards }

  it { expect(subject.moyennes_metriques).to eq({ ccf: 12, syntaxe: 2 }) }

  it { expect(subject.ecarts_types_metriques).to eq({ ccf: 3, syntaxe: 0.5 }) }

  it { expect(subject.standardise(:ccf, 12 + 3)).to eq 1 }
end
