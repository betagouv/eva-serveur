# frozen_string_literal: true

require 'rails_helper'

describe SituationConfiguration do
  it { should validate_uniqueness_of(:situation_id).scoped_to(:campagne_id).case_insensitive }
end
