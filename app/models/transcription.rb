# frozen_string_literal: true

class Transcription < ApplicationRecord
  has_one_attached :audio

  enum categorie: { intitule: 0, modalite_reponse: 1 }
end
