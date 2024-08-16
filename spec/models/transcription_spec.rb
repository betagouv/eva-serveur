# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transcription, type: :model do
  it { is_expected.to have_one_attached :audio }
  it { is_expected.to define_enum_for(:categorie).with_values(%i[intitule modalite_reponse]) }

  describe 'validations' do
    let(:transcription) { Transcription.new }
    it 'ne valide pas un audio de type wav' do
      transcription.audio.attach(io: Rails.root.join('spec/support/bravo.wav').open,
                                 filename: 'bravo.wav')
      expect(transcription.valid?).to be(false)
      expect(transcription.errors[:audio]).to include('doit être un fichier MP3 ou MP4')
      transcription.save
      expect(transcription.audio).to_not be_attached
    end

    it 'valide un audio de type mp3' do
      transcription.audio.attach(io: Rails.root.join('spec/support/alcoolique.mp3').open,
                                 filename: 'alcoolique.mp3')
      expect(transcription.valid?).to be(true)
      transcription.save
      expect(transcription.audio).to be_attached
    end
  end
end
