# frozen_string_literal: true

require 'rails_helper'

describe Evenement, type: :model do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_presence_of :date }
  it { is_expected.to validate_presence_of :session_id }
  it { is_expected.to allow_value(nil).for :donnees }
  it do
    is_expected.to belong_to(:partie)
      .with_primary_key(:session_id)
      .with_foreign_key(:session_id)
  end
end
