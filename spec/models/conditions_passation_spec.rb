require 'rails_helper'

RSpec.describe ConditionsPassation, type: :model do
  it { is_expected.to belong_to(:evaluation) }
end
