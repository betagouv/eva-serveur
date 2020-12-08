# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SourceAide, type: :model do
  it { should validate_presence_of(:titre) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:categorie) }
  it { should validate_presence_of(:type_document) }

  describe 'retourne les sources par catégories' do
    let!(:source1) { create :source_aide, categorie: 'prise_en_main' }
    let!(:source2) { create :source_aide, categorie: 'prise_en_main' }
    let!(:source3) { create :source_aide, categorie: 'animer_restituer' }
    it do
      expect(SourceAide.sources_par_categorie).to eql(
        {
          'prise_en_main' => [source1, source2],
          'animer_restituer' => [source3]
        }
      )
    end
  end
end
