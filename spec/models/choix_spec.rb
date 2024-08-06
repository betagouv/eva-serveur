# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Choix, type: :model do
  it { is_expected.to validate_presence_of :intitule }
  it { is_expected.to validate_presence_of :type_choix }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to have_one_attached(:audio) }

  it do
    expect(subject).to define_enum_for(:type_choix)
      .with_values(%i[bon mauvais abstention])
  end

  describe '#as_json' do
    it 'serialise les champs' do
      json = subject.as_json
      expect(json.keys).to match_array(%w[id intitule type_choix nom_technique])
    end
  end
end
