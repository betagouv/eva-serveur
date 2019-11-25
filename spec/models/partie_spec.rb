# frozen_string_literal: true

require 'rails_helper'

describe Partie do
  let(:partie) { described_class.new session_id: 'session_id' }

  it { should validate_presence_of(:session_id) }
  it { should belong_to(:evaluation) }
  it { should belong_to(:situation) }
end
