# frozen_string_literal: true

class Choix < ApplicationRecord
  validates :intitule, :type_choix, :nom_technique, presence: true
  enum :type_choix, { bon: 0, mauvais: 1, abstention: 2 }
  has_one_attached :audio

  acts_as_list scope: :question_id

  def as_json(_options = nil)
    slice(:id, :intitule, :type_choix, :nom_technique)
  end
end
