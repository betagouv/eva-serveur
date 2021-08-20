# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  it { is_expected.to have_many(:questionnaires_questions).dependent(:destroy) }

  it { is_expected.to validate_presence_of :libelle }
end
