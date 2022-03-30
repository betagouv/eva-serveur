# frozen_string_literal: true

class Evenement < ApplicationRecord
  validates :nom, :date, :session_id, presence: true
  validates_uniqueness_of :position, scope: :session_id
  belongs_to :partie, foreign_key: :session_id, primary_key: :session_id
  delegate :situation, :evaluation, to: :partie

  def fin_situation?
    nom == 'finSituation'
  end
end
