class SiretInput < Formtastic::Inputs::StringInput
  ANNUAIRE_SIRET_URL = "https://annuaire-entreprises.data.gouv.fr/"
  ANNUAIRE_SIRET_URL_CAMPAGNE_PRO_CONNECT = "#{ANNUAIRE_SIRET_URL}?mtm_campaign=proconnect"

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
    input_html_options.dup.tap do |html|
      html.merge!(siret_input_html_attributes)
      value = formatted_siret_value
      html[:value] = value if value.present?
    end
  end

  def siret_input_html_attributes
    {
      "data-siret-input" => "true",
      maxlength: 18, # 14 chiffres + 4 espaces (format 3-3-3-5)
      inputmode: "numeric",
      autocomplete: "off",
      pattern: "[0-9\\s]*",
      placeholder: "123 456 789 01234"
    }
  end

  def formatted_siret_value
    return nil unless object.respond_to?(method)

    raw = object.public_send(method)
    format_siret_display(raw) if raw.present?
  end

  def format_siret_display(raw)
    digits = raw.to_s.gsub(/\D/, "")[0, 14]
    return "" if digits.blank?

    # Format 3-3-3-5 : 123 456 789 01234
    [ digits[0, 3], digits[3, 3], digits[6, 3], digits[9, 5] ].reject(&:empty?).join(" ")
  end

  def annuaire_siret_link_html
    template.capture do
      template.content_tag(:p) do
        template.render LienComponent.new(
          I18n.t("formtastic.inputs.siret.lien.description"),
          ANNUAIRE_SIRET_URL,
          nouvelle_fenetre: true
        )
      end
    end
  end
end
