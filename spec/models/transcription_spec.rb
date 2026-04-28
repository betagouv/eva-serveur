require 'rails_helper'

RSpec.describe Transcription, type: :model do
  it { is_expected.to have_one_attached :audio }

  it {
    expect(subject).to define_enum_for(:categorie).with_values(%i[intitule modalite_reponse
                                                                  consigne])
  }

  describe 'validations' do
    let(:transcription) { described_class.new }

    it 'ne valide pas un audio de type wav' do
      transcription.audio.attach(io: Rails.root.join('spec/support/bravo.wav').open,
                                 filename: 'bravo.wav')

      expect(transcription.valid?).to be(false)
      expect(transcription.errors[:audio]).to include('doit être un fichier MP3 ou MP4')
    end

    it 'valide un audio de type mp3' do
      transcription.audio.attach(io: Rails.root.join('spec/support/alcoolique.mp3').open,
                                 filename: 'alcoolique.mp3')

      expect(transcription.valid?).to be(true)
      transcription.save
      expect(transcription.audio).to be_attached
      expect(transcription.audio.blob.filename.to_s).to eq("alcoolique.mp3")
      expect(transcription.audio.blob.content_type).to eq("audio/mpeg")
    end
  end

  describe "#audio_extension" do
    let(:transcription) { described_class.new }

    context "quand aucun audio n'est attaché" do
      it "n'ajoute pas d'erreur" do
        transcription.valid?

        expect(transcription.errors[:audio]).to be_empty
      end
    end

    context "quand l'extension est .mp3" do
      it "est valide" do
        transcription.audio.attach(
          io: Rails.root.join("spec/support/alcoolique.mp3").open,
          filename: "audio.mp3",
          content_type: "audio/mpeg"
        )

        expect(transcription).to be_valid
        expect(transcription.errors[:audio]).to be_empty
      end
    end

    context "quand l'extension est en majuscule (.MP3)" do
      it "est valide (downcase appliqué)" do
        transcription.audio.attach(
          io: Rails.root.join("spec/support/alcoolique.mp3").open,
          filename: "audio.MP3",
          content_type: "audio/mpeg"
        )

        expect(transcription).to be_valid
        expect(transcription.errors[:audio]).to be_empty
      end
    end

    context "quand le fichier n'a pas d'extension" do
      it "est invalide sur invalid_extension" do
        transcription.audio.attach(
          io: Rails.root.join("spec/support/alcoolique.mp3").open,
          filename: "audio_sans_extension",
          content_type: "audio/mpeg"
        )

        expect(transcription).not_to be_valid
        expect(transcription.errors.details[:audio]).to include(error: :invalid_extension)
        expect(transcription.errors[:audio]).to include(
              "doit avoir une extension valide (.mp3, .mp4)"
              )
      end
    end

    context "quand l'extension n'est pas autorisée (.wav)" do
      it "est invalide sur invalid_extension" do
        transcription.audio.attach(
          io: Rails.root.join("spec/support/alcoolique.mp3").open,
          filename: "audio.wav",
          content_type: "audio/mpeg"
        )

        expect(transcription).not_to be_valid
        expect(transcription.errors.details[:audio]).to include(error: :invalid_extension)
      end
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
