# frozen_string_literal: true

module CguHelper
  def lien_cgu(parametres = {})
    link_to(I18n.t('.cgu_helper.lien_cgu'), '/cgu/', parametres.merge(target: '_blank'))
  end
end
