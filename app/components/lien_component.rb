# frozen_string_literal: true

class LienComponent < ViewComponent::Base
  def initialize(body, url, params)
    @body = body
    @url = url
    @params = params
  end
end
