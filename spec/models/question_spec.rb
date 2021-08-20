# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  it { is_expected.to validate_presence_of :intitule }

  it { is_expected.to have_one(:illustration_attachment) }
end
