# frozen_string_literal: true

require 'rails_helper'

describe Compte do
  it { should validate_inclusion_of(:role).in_array(%w[administrateur organisation]) }
end
