# frozen_string_literal: true

class Question < ApplicationRecord
  validates :intitule, presence: true
  has_many :choix, -> { order(position: :asc) }

  accepts_nested_attributes_for :choix, allow_destroy: true

  def display_name
    intitule
  end
end
