# frozen_string_literal: true

require 'rails_helper'

describe Evenement, type: :model do
  it { should validate_presence_of :nom }
  it { should allow_value(nil).for :donnees }
  it { should validate_presence_of :date }
  it do
    should belong_to(:partie)
      .with_primary_key(:session_id)
      .with_foreign_key(:session_id)
  end
end
