# frozen_string_literal: true

require 'rails_helper'

describe MiseEnAction, type: :model do
  it { is_expected.to belong_to(:evaluation) }
  it do
    subject.evaluation = create(:evaluation, :avec_mise_en_action)
    is_expected.to validate_uniqueness_of(:evaluation_id).case_insensitive
  end

  it "valide que effectuee n'est pas vide" do
    should_not allow_value(nil).for(:effectuee)
    should allow_value(true).for(:effectuee)
    should allow_value(false).for(:effectuee)
  end
end
