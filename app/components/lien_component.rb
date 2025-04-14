# frozen_string_literal: true

class LienComponent < ViewComponent::Base
  def initialize(body, url, externe: false, aria: nil)
    @body = body
    @url = url
    @externe = externe
    @params = { aria: aria.dup }
    ajoute_params_externe(body, aria) if externe
  end

  def ajoute_params_externe(body, aria)
    description = description_extern(body)
    if aria.present? && aria[:label].present?
      description = description_extern(aria[:label])
      @params[:aria][:label] = description
    end
    @params = @params.merge({ target: "_blank", title: description, rel: "noopener" })
  end

  def description_extern(description)
    I18n.t(".lien_externe", texte_du_lien: description)
  end
end
