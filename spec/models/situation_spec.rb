# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Situation, type: :model do
  it { should validate_presence_of :libelle }
  it { should validate_presence_of :nom_technique }
  it { should validate_uniqueness_of :nom_technique }
end
