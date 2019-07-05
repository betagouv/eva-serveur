# frozen_string_literal: true

class Evenement < ApplicationRecord
  belongs_to :situation
  belongs_to :evaluation

  validates :nom, :date, :situation, :session_id, presence: true
end
