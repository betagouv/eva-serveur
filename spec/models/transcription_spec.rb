# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transcription, type: :model do
  it { is_expected.to have_one_attached :audio }
  it { is_expected.to define_enum_for(:categorie).with_values(%i[intitule modalite_reponse]) }

  describe 'validations' do
    let(:transcription) { described_class.new }

    it 'ne valide pas un audio de type wav' do
      transcription.audio.attach(io: Rails.root.join('spec/support/bravo.wav').open,
                                 filename: 'bravo.wav')
      expect(transcription.valid?).to be(false)
      expect(transcription.errors[:audio]).to include('doit être un fichier MP3 ou MP4')
      transcription.save
      expect(transcription.audio).not_to be_attached
    end

    it 'valide un audio de type mp3' do
      transcription.audio.attach(io: Rails.root.join('spec/support/alcoolique.mp3').open,
                                 filename: 'alcoolique.mp3')
      expect(transcription.valid?).to be(true)
      transcription.save
      expect(transcription.audio).to be_attached
    end
  end

  describe '.complete?' do
    let(:transcription) { described_class.new }

    context 'quand il y a un écrit et un audio' do
      it 'retourne true' do
        transcription.ecrit = 'Some text'
        transcription.audio.attach(io: Rails.root.join('spec/support/alcoolique.mp3').open,
                                   filename: 'alcoolique.mp3')
        expect(transcription.complete?).to be(true)
      end
    end

    context "quand il n'y a pas d'écrit" do
      it 'retourne false' do
        transcription.audio.attach(io: Rails.root.join('spec/support/alcoolique.mp3').open,
                                   filename: 'alcoolique.mp3')
        expect(transcription.complete?).to be(false)
      end
    end

    context "quand il n'y a pas d'audio" do
      it 'retourne false' do
        transcription.ecrit = 'Some text'
        expect(transcription.complete?).to be(false)
      end
    end

    context "quand il n'y a ni écrit ni audio" do
      it 'retourne false' do
        expect(transcription.complete?).to be(false)
      end
    end
  end
end
