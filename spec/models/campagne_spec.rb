# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campagne, type: :model do
  it { should validate_presence_of :libelle }
  it { should validate_presence_of :code }
  it { should validate_uniqueness_of :code }
end
