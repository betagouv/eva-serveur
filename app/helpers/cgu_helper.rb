# frozen_string_literal: true

module CguHelper
  def lien_cgu
    render LienComponent.new(I18n.t('.cgu_helper.lien_cgu'),
                             '/cgu/',
                             class: 'lien-externe', target: '_blank')
  end
end
