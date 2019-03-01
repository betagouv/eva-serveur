# frozen_string_literal: true

require 'rails_helper'

describe Evenement, type: :model do
  it { should validate_presence_of :type_evenement }
  it { should validate_presence_of :description }
  it { should validate_presence_of :date }
  it { should validate_presence_of :session_id }
  it { should validate_presence_of :situation }
end
