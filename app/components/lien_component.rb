# frozen_string_literal: true

class LienComponent < ViewComponent::Base
  def initialize(body, url, externe: false)
    @body = body
    @url = url
    @externe = externe
    return unless externe

    @params = { target: '_blank',
                title: I18n.t('.lien_externe', texte_du_lien: body),
                rel: 'noopener',
                class: 'lien-externe' }
  end
end
