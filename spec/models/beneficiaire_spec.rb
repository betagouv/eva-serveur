# frozen_string_literal: true

require 'rails_helper'

describe Beneficiaire do
  it { is_expected.to validate_presence_of :nom }
end
