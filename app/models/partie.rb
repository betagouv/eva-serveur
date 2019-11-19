# frozen_string_literal: true

class Partie
  delegate_missing_to :restitution

  def initialize(session_id)
    @session_id = session_id
  end

  def restitution
    @restitution ||= FabriqueRestitution.depuis_session_id(@session_id)
  end
end
