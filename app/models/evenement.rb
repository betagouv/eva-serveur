# frozen_string_literal: true

class Evenement < ApplicationRecord
  validates :type_evenement, :description, :date, presence: true
  before_validation :formate_date, on: :create

  private

  def formate_date
    time_formate = Time.at(date.to_i / 1000.0)
    self.date = DateTime.parse(time_formate.to_s)
  end
end
