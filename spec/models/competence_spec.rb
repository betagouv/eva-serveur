# frozen_string_literal: true

require 'rails_helper'

describe Competence do
  it { expect(described_class::NIVEAU_4).to eql(4) }
  it { expect(described_class::NIVEAU_3).to eql(3) }
  it { expect(described_class::NIVEAU_2).to eql(2) }
  it { expect(described_class::NIVEAU_1).to eql(1) }
  it { expect(described_class::NIVEAU_INDETERMINE).to eql(:indetermine) }
end
