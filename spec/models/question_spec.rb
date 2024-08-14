# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :nom_technique }
  fit { is_expected.to validate_uniqueness_of :nom_technique }
  it { is_expected.to have_many(:transcriptions).dependent(:destroy) }
  it { is_expected.to accept_nested_attributes_for(:transcriptions).allow_destroy(true) }
  it { is_expected.to have_one_attached(:illustration) }
end
