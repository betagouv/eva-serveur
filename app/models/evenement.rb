# frozen_string_literal: true

class Evenement < ApplicationRecord
  validates :nom, :date, :session_id, presence: true

  scope :campagne, lambda { |campagne|
    sessions_ids_campagne = Partie.joins(evaluation: :campagne)
                                  .where(evaluations: { campagnes: { code: campagne } })
                                  .select(:session_id)
    where(session_id: sessions_ids_campagne)
  }

  def self.ransackable_scopes(_auth_object = nil)
    %i[campagne]
  end
end
