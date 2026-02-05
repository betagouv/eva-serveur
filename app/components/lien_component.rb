class LienComponent < ViewComponent::Base
  def initialize(body = nil, url = nil, externe: false, aria: nil, data: nil, class: nil,
**html_options)
    @body = body
    @url = url
    @externe = externe
    @params = { aria: aria&.dup || {} }
    @data = data || {}
    @class = binding.local_variable_get(:class)
    @html_options = html_options

    ajoute_params_externe(body, aria) if externe
    merge_html_options
  end

  def ajoute_params_externe(body, aria)
    description = description_extern(body || content_text)
    if aria.present? && aria[:label].present?
      description = description_extern(aria[:label])
      @params[:aria][:label] = description
    end
    @params = @params.merge({ target: "_blank", title: description, rel: "noopener external" })
  end

  def merge_html_options
    @params[:class] = @class if @class.present?
    @params[:data] = @data if @data.present?
    @params.merge!(@html_options)
  end

  def description_extern(description)
    I18n.t(".lien_externe", texte_du_lien: description)
  end

  def body_content
    if content.present?
      content
    elsif @body.present?
      @body
    else
      ""
    end
  end

  def content_text
    # Pour obtenir le texte du contenu pour la description externe
    # On utilise une version simplifiée si c'est du HTML
    @body || ""
  end
end
