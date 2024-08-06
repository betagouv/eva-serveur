# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transcription, type: :model do
  it { is_expected.to have_one_attached :audio }
  it { is_expected.to define_enum_for(:categorie).with_values(%i[intitule modalite_reponse]) }
end
