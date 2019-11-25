# frozen_string_literal: true

class Partie < ApplicationRecord
  belongs_to :evaluation
  belongs_to :situation

  validates :session_id, presence: true
  # delegate_missing_to :restitution

  def restitution
    @restitution ||= FabriqueRestitution.depuis_session_id(session_id)
  end
end
