# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  it { should have_many(:questionnaires_questions).dependent(:destroy) }

  it { should validate_presence_of :libelle }
end
