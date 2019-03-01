# frozen_string_literal: true

class Evenement < ApplicationRecord
  validates :type_evenement, :description, :date, :situation, :session_id, presence: true
end
