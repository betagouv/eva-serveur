# frozen_string_literal: true

class Evenement < ApplicationRecord
  validates :nom, :donnees, :date, :situation, :session_id, presence: true
end
