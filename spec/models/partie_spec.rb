# frozen_string_literal: true

require 'rails_helper'

describe Partie do
  it { should validate_presence_of(:session_id) }
  it { should belong_to(:evaluation) }
  it { should belong_to(:situation) }
end
