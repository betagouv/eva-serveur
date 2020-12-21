# frozen_string_literal: true

require 'rails_helper'

describe Evaluation do
  it { should validate_presence_of :nom }
  it { should validate_presence_of :campagne }
  it { should belong_to :campagne }
end
