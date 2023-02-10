# frozen_string_literal: true

class MiseEnAction < ApplicationRecord
  belongs_to :evaluation

  validates :evaluation_id, uniqueness: true
  validates :effectuee, absence: false, inclusion: { in: [true, false] }

  before_save :enregistre_date

  acts_as_paranoid

  def enregistre_date
    return unless repondue_le.nil?

    self.repondue_le = Time.zone.now
  end
end
