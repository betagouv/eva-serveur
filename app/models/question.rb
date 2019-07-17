# frozen_string_literal: true

class Question < ApplicationRecord
  validates :intitule, presence: true
end
