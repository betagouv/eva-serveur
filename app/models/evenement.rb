# frozen_string_literal: true

class Evenement < ApplicationRecord
  validates :nom, :date, :session_id, presence: true
  belongs_to :partie, foreign_key: :session_id, primary_key: :session_id
  delegate :situation, :evaluation, to: :partie
end
