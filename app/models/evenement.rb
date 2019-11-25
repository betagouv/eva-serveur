# frozen_string_literal: true

class Evenement < ApplicationRecord
  belongs_to :situation
  belongs_to :evaluation
  belongs_to :partie, foreign_key: :session_id, primary_key: :session_id

  validates :nom, :date, :situation, :session_id, :partie, presence: true

  before_validation :assure_la_presence_de_partie

  private

  def assure_la_presence_de_partie
    return if partie.present?

    build_partie(evaluation_id: evaluation_id, situation_id: situation_id)
  end
end
