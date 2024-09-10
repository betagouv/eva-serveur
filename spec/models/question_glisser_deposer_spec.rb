# frozen_string_literal: true

require 'rails_helper'

describe QuestionGlisserDeposer, type: :model do
  it { is_expected.to have_many(:reponse).with_foreign_key(:question_id) }
end
