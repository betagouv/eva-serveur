# frozen_string_literal: true

class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation

  validates :session_id, presence: true

  delegate :campagne, to: :evaluation
  has_many :evenements, foreign_key: :session_id, primary_key: :session_id
end
