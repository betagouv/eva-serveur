# frozen_string_literal: true

class BilanEvaProComponent < ViewComponent::Base
  include MarkdownHelper

  def initialize(palier:)
    @palier = palier
  end
end
