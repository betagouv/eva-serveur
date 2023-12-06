# frozen_string_literal: true

class LienComponent < ViewComponent::Base
  def initialize(body, url, externe: false)
    @body = body
    @url = url
    @externe = externe
    @params = { target: '_blank' } if externe
  end
end
