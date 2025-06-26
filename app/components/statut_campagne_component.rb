# frozen_string_literal: true

class StatutCampagneComponent < ViewComponent::Base
  def initialize(campagne_active: true, campagne_privee: false)
    @campagne_active = campagne_active
    @campagne_privee = campagne_privee
  end
end
