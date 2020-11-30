# frozen_string_literal: true

require 'rails_helper'

describe Actualite do
  it { should validate_presence_of(:titre) }
  it { should validate_presence_of(:contenu) }
  it { should validate_presence_of(:categorie) }

  context 'limite la taille du titre pour le tableau de bord' do
    it { should validate_length_of(:titre).is_at_most(60) }
  end
end
