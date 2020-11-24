# frozen_string_literal: true

require 'rails_helper'

describe Actualite do
  it { should validate_presence_of(:titre) }
  it { should validate_presence_of(:contenu) }
  it { should validate_presence_of(:categorie) }
end
