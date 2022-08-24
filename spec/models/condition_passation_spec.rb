# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConditionPassation, type: :model do
  it { is_expected.to belong_to(:evaluation) }
end
