# frozen_string_literal: true

require 'rails_helper'

describe Evaluation do
  it { is_expected.to validate_presence_of :nom }
  it { is_expected.to validate_presence_of :debutee_le }
  it { is_expected.to belong_to :campagne }
  it { should accept_nested_attributes_for :beneficiaire }
  it { is_expected.to have_one :conditions_passation }
  it { should accept_nested_attributes_for :conditions_passation }
  it { is_expected.to have_one :donnee_sociodemographique }
  it { should accept_nested_attributes_for :donnee_sociodemographique }
end
