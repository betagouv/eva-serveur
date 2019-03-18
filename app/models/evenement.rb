# frozen_string_literal: true

class Evenement < ApplicationRecord
  validates :nom, :date, :situation, :session_id, presence: true
end
