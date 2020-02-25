# frozen_string_literal: true

require_relative '../decorators/evenement_maintenance'
require_relative '../decorators/evenement_securite'

class Evenement < ApplicationRecord
  DECORATORS = {
    maintenance: EvenementMaintenance,
    securite: EvenementSecurite
  }.freeze

  validates :nom, :date, presence: true
  belongs_to :partie, foreign_key: :session_id, primary_key: :session_id
  delegate :situation, :evaluation, to: :partie
end
