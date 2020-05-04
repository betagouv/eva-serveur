# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

describe Compte do
  it { should validate_inclusion_of(:role).in_array(%w[administrateur organisation]) }
  it { should belong_to(:structure).optional }
end
