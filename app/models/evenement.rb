# frozen_string_literal: true

class Evenement < ApplicationRecord
  has_one :partie, foreign_key: :session_id, primary_key: :session_id

  validates :nom, :date, :session_id, presence: true
end
