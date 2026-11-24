require 'rails_helper'

RSpec.describe SourceAide, type: :model do
  it { is_expected.to validate_presence_of(:titre) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:categorie) }
  it { is_expected.to validate_presence_of(:type_document) }

  describe 'retourne les sources par catégories' do
    let!(:source3) { create :source_aide, categorie: :animer_restituer }
    let!(:source1) { create :source_aide, categorie: :prise_en_main }
    let!(:source2) { create :source_aide, categorie: :prise_en_main }

    it do
      expect(described_class.sources_par_categorie.to_a).to eql(
        [
          [ 'prise_en_main', [ source1, source2 ] ],
          [ 'animer_restituer', [ source3 ] ]
        ]
      )
    end
  end

  describe "#domaine" do
    it "donne le domaine du lien" do
      expect(described_class.new(url: "https://www.youtube.com/watch?v=1").domaine)
        .to eq "www.youtube.com"
    end

    it "garde le lien tel quel quand il n'est pas une URL valide" do
      expect(described_class.new(url: "pas une url").domaine).to eq "pas une url"
    end
  end
end
