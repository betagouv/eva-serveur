# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  it { should validate_presence_of :libelle }
  it { should validate_presence_of :questions }
end
