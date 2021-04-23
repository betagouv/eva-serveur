# frozen_string_literal: true

require 'rails_helper'

describe ParcoursType, type: :model do
  it { should validate_presence_of :libelle }
  it { should validate_presence_of :duree_moyenne }
  it { should validate_presence_of :nom_technique }
  it { should validate_uniqueness_of :nom_technique }

  it { should have_many(:situations_configurations).order(position: :asc).dependent(:destroy) }
end
