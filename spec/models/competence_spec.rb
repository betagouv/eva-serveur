require 'rails_helper'

describe Competence do
  it { expect(described_class::NIVEAU_4).to be(4) }
  it { expect(described_class::NIVEAU_3).to be(3) }
  it { expect(described_class::NIVEAU_2).to be(2) }
  it { expect(described_class::NIVEAU_1).to be(1) }
  it { expect(described_class::NIVEAU_INDETERMINE).to be(:indetermine) }
end
