class SiretInput < Formtastic::Inputs::StringInput
  def initialize(builder, template, object, object_name, method, options)
    super
    @options[:hint] ||= I18n.t("formtastic.inputs.siret.hint")
  end
  def to_html
    input_wrapping do
      label_html <<
      siret_input_html <<
      error_html
    end <<
    annuaire_siret_link_html
  end

  private

  def siret_input_html
    builder.text_field(
      method,
      input_html_options_with_constraints
    )
  end

  def input_html_options_with_constraints
    html = input_html_options.dup
    html[:maxlength] ||= 14
    html[:pattern] ||= "[0-9\\s]{14}"
    html
  end

  def annuaire_siret_link_html
    template.capture do
      template.content_tag(:p) do
        template.render LienComponent.new(
          I18n.t("formtastic.inputs.siret.lien.description"),
          I18n.t("formtastic.inputs.siret.lien.url"),
          nouvelle_fenetre: true
        )
      end
    end
  end
end
