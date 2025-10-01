require 'rails_helper'

describe Partie do
  it { is_expected.to validate_presence_of(:session_id) }
  it { is_expected.to validate_uniqueness_of(:session_id) }
  it { is_expected.to belong_to(:evaluation) }
  it { is_expected.to belong_to(:situation) }
end
