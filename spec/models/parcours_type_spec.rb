# frozen_string_literal: true

require 'rails_helper'

describe ParcoursType, type: :model do
  it { is_expected.to validate_presence_of :libelle }
  it { is_expected.to validate_presence_of :duree_moyenne }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of :nom_technique }

  it do
    is_expected
      .to have_many(:situations_configurations).order(position: :asc).dependent(:destroy)
  end
end
