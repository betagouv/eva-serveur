# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SourceAide, type: :model do
  it { should validate_presence_of(:titre) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:categorie) }
  it { should validate_presence_of(:type_document) }
end
