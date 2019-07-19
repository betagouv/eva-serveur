# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Choix, type: :model do
  it { should validate_presence_of :intitule }
  it { should validate_presence_of :type_choix }
  it do
    should define_enum_for(:type_choix)
      .with_values(%i[bon mauvais abstention])
  end

  describe '#as_json' do
    it 'serialise les champs' do
      json = subject.as_json
      expect(json.keys).to match_array(%w[id intitule])
    end
  end
end
