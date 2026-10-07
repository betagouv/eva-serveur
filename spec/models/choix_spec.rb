require 'rails_helper'

RSpec.describe Choix, type: :model do
  it { is_expected.to validate_presence_of :type_choix }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to validate_uniqueness_of(:nom_technique).scoped_to(:question_id) }
  it { is_expected.to have_one_attached(:audio) }
  it { is_expected.to have_one_attached(:illustration) }

  it do
    expect(subject).to define_enum_for(:type_choix)
      .with_values(%i[bon mauvais abstention bonus acceptable])
  end

  describe '#as_json' do
    it 'serialise les champs' do
      json = subject.as_json
      expect(json.keys).to match_array(%w[id intitule type_choix nom_technique score])
    end
  end

  describe 'validations' do
    let(:choix) do
      described_class.new(intitule: 'intitule', type_choix: :bon, nom_technique: 'nom_technique')
    end

    it 'ne valide pas un audio de type wav' do
      choix.audio.attach(io: Rails.root.join('spec/support/bravo.wav').open,
                         filename: 'bravo.wav')
      expect(choix.valid?).to be(false)
      expect(choix.errors[:audio]).to include('doit être un fichier MP3 ou MP4')
      choix.save
      expect(choix.audio).not_to be_attached
    end

    it 'accepte un score saisi en JSON' do
      choix.score = '{"cout": 3, "numerique": 2}'
      expect(choix.valid?).to be(true)
      expect(choix.score).to eq('cout' => 3, 'numerique' => 2)
    end

    it 'vide le score quand la saisie est vide' do
      choix.score = ''
      expect(choix.valid?).to be(true)
      expect(choix.score).to be_nil
    end

    it "refuse un score qui n'est pas un objet JSON" do
      [ 'risques: 3', '3' ].each do |saisie|
        choix.score = saisie
        expect(choix.valid?).to be(false)
        expect(choix.errors[:score]).to include("n'est pas un objet JSON valide")
      end
    end

    it 'conserve la saisie invalide pour la réafficher' do
      choix.score = 'risques: 3'
      expect(choix.score_json).to eq 'risques: 3'
    end

    it 'valide un audio de type mp3' do
      choix.audio.attach(io: Rails.root.join('spec/support/alcoolique.mp3').open,
                         filename: 'alcoolique.mp3')
      expect(choix.valid?).to be(true)
      choix.save
      expect(choix.audio).to be_attached
    end
  end
end
