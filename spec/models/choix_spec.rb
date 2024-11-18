# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Choix, type: :model do
  it { is_expected.to validate_presence_of :type_choix }
  it { is_expected.to validate_presence_of :nom_technique }
  it { is_expected.to have_one_attached(:audio) }
  it { is_expected.to have_one_attached(:illustration) }

  it do
    expect(subject).to define_enum_for(:type_choix)
      .with_values(%i[bon mauvais abstention bonus acceptable])
  end

  describe '#as_json' do
    it 'serialise les champs' do
      json = subject.as_json
      expect(json.keys).to match_array(%w[id intitule type_choix nom_technique])
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

    it 'valide un audio de type mp3' do
      choix.audio.attach(io: Rails.root.join('spec/support/alcoolique.mp3').open,
                         filename: 'alcoolique.mp3')
      expect(choix.valid?).to be(true)
      choix.save
      expect(choix.audio).to be_attached
    end
  end
end
