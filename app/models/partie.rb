# frozen_string_literal: true

class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation
  has_many :evenements, foreign_key: :session_id, primary_key: :session_id

  validates :session_id, presence: true

  delegate :campagne, to: :evaluation
end
