# frozen_string_literal: true

class Evenement < ApplicationRecord
  DECORATORS = {
    maintenance: EvenementMaintenanceDecorator,
    securite: EvenementSecuriteDecorator
  }.freeze

  validates :nom, :date, presence: true
  belongs_to :partie, foreign_key: :session_id, primary_key: :session_id
  delegate :situation, :evaluation, to: :partie
end
