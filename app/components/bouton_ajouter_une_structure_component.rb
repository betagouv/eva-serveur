# frozen_string_literal: true

class BoutonAjouterUneStructureComponent < ViewComponent::Base
  def initialize(current_compte)
    @current_compte = current_compte
  end
end
