require 'rails_helper'

describe StructureOpco, type: :model do
  describe 'validations' do
    it { expect(subject).to validate_presence_of(:opco) }
  end
end
