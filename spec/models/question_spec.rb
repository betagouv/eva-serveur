# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  it { should validate_presence_of :intitule }
  it { should have_one(:illustration_attachment) }
end
