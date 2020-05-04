# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Structure, type: :model do
  it { should validate_presence_of(:nom) }
  it { should validate_presence_of(:code_postal) }
end
