require 'rails_helper'

RSpec.describe AnnonceGenerale, type: :model do
  it { is_expected.to validate_presence_of(:texte) }
end
