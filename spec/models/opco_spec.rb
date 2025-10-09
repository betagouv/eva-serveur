require 'rails_helper'

RSpec.describe Opco, type: :model do
  it { is_expected.to validate_presence_of(:nom) }
end
