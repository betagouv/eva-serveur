# frozen_string_literal: true

module TranscriptionHelper
  def tag_audio(transcription)
    return if transcription.nil? || !transcription.audio.attached?

    audio_tag cdn_for(transcription.audio), controls: true
  end
end
