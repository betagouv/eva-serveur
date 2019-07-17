# frozen_string_literal: true

class Question < ApplicationRecord
  validates :intitule, presence: true

  validates :intitule, presence: true

  def display_name
    intitule
  end
end
