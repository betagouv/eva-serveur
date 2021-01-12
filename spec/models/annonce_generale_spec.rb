# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnonceGenerale, type: :model do
  it { should validate_presence_of(:texte) }
end
