# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Aide::QuestionFrequente do
  it { is_expected.to validate_presence_of(:question) }
  it { is_expected.to validate_presence_of(:reponse) }
end
