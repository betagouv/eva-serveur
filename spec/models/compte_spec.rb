# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Compte do
  it { should validate_inclusion_of(:role).in_array(%w[administrateur organisation]) }

  describe :administrateur? do
    it 'retourne true' do
      expect(Compte.new(role: 'administrateur').administrateur?).to be true
    end

    it 'retourne false' do
      expect(Compte.new(role: 'organisation').administrateur?).to be false
    end
  end
end
