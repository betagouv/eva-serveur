# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Aide::QuestionFrequente do
  it { should validate_presence_of(:question) }
  it { should validate_presence_of(:reponse) }
end
